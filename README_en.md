# Flutter E2E Investigation

[🇯🇵 日本語版 / Japanese](./README.md)

A project to verify **the next stage of AI-driven development**.

By combining Claude Code + MCP (Maestro / Dart), AI autonomously performs **design, implementation, verification, and self-review**.

## Why This Matters?

### Traditional AI-Driven Development: Pair Programming Style

```
Human <-> AI
  ^
 Confirmation/judgment at every step
```

Humans review code after each implementation, and manually verify functionality.
AI is "the one who does the work", humans are "always watching beside".

**Problem**: High time cost for humans, unable to fully leverage AI productivity.

### Target State: Delegation to Team Members

```
Human (Lead Engineer)
  | Task assignment
  v
AI (Team Member)
  |-- Implementation
  |-- Verification (E2E tests, error checking)
  |-- Self-review (multi-model validation)
  |-- Report after improving quality
  v
Human (Final review/approval)
```

**Change**: Humans become "final reviewers", AI autonomously ensures quality.

### Same as Human Team Management

```
Junior:
  1. Implement
  2. Self-verify
  3. Confirm tests pass
  4. Self-review (eliminate obvious issues)
  5. "Verified, please review"
    |
    v
Senior: Review only essential parts
```

Only then can one senior manage multiple juniors.
**Same for AI agents.** Without self-verification, humans become the bottleneck.

### Scalability

```
                    +-- AI Agent A (Feature implementation)
                    |    +-- Self-test & review
Human (Lead) -------+-- AI Agent B (Bug fix)
                    |    +-- Self-test & review
                    +-- AI Agent C (Refactoring)
                         +-- Self-test & review
```

Running AI agents in parallel requires a system where humans don't become bottlenecks.
This project is **a proof of concept for that foundational technology**.

## What's This?

This repository demonstrates AI (Claude Code) **autonomously** executing:

- Flutter app design and implementation
- Verification through E2E testing
- Self-review (Gemini CLI + Claude subagent)
- Git commit and push

**Humans only provide instructions and final review.**

## Demo: Image Attachment Feature Implementation

From a single instruction "implement image attachment feature", Claude Code:

1. Proposes design and confirms with user
2. Adds necessary packages
3. Implements model, repository, and provider
4. Creates UI widgets
5. **Launches app on emulator**
6. **Actually operates and verifies functionality**
7. Reports results with screenshots

## Architecture

```
+-------------------------------------------------------------+
|                       Claude Code                            |
+-------------------------------------------------------------+
|  Plan Mode    |  Implementation  |  E2E Testing             |
|  - Design     |  - Code gen      |  - App launch            |
|  - Questions  |  - File editing  |  - UI operations         |
|  - Approval   |  - Progress mgmt |  - Screenshots           |
+-------+-------+--------+---------+-----------+---------------+
        |                |                     |
        v                v                     v
   AskUserQuestion    Edit/Write         MCP Servers
                                              |
                    +-------------------------+-------------------------+
                    |                         |                         |
                    v                         v                         v
              +----------+             +----------+             +----------+
              | Dart MCP |             | Maestro  |             | Flutter  |
              |  Server  |             |   MCP    |             |   App    |
              +----+-----+             +----+-----+             +----------+
                   |                        |                         ^
                   |  - App launch          |  - Screenshots          |
                   |  - Hot reload          |  - Tap operations       |
                   |  - Widget tree         |  - Text input           |
                   |  - Error retrieval     |  - View hierarchy       |
                   |                        |                         |
                   +------------------------+-------------------------+
```

## Key Features

### Dart MCP Server
- `launch_app`: Launch Flutter app
- `connect_dart_tooling_daemon`: DTD connection
- `hot_reload` / `hot_restart`: Instant code change reflection
- `get_widget_tree`: Get widget structure
- `get_runtime_errors`: Get error information

### Maestro MCP
- `take_screenshot`: Capture screenshots
- `inspect_view_hierarchy`: UI element list (lightweight)
- `tap_on`: Tap by text/ID specification
- `input_text`: Text input
- `run_flow`: Execute Maestro flows

### Why Maestro MCP? (vs Mobile MCP)

There are two mobile automation MCPs: [Maestro MCP](https://github.com/mobile-next/maestro-mcp) and [Mobile MCP](https://github.com/mobile-next/mobile-mcp).

#### Feature Comparison

| Feature | Maestro MCP | Mobile MCP |
|---------|:-----------:|:----------:|
| **ID/text-based tap** | ✅ `tap_on(id="xxx")` | ❌ Coordinates only |
| **Coordinate-based tap** | △ Via run_flow | ✅ Direct support |
| **Device buttons (HOME/BACK)** | ❌ | ✅ |
| **Screen orientation change** | ❌ | ✅ |
| **App install/uninstall** | ❌ | ✅ |
| **YAML flow execution** | ✅ | ❌ |
| **Documentation reference** | ✅ | ❌ |

#### Element Retrieval Differences

| Item | Maestro MCP | Mobile MCP |
|------|-------------|------------|
| **Format** | CSV (hierarchical) | JSON (flat) |
| **Information** | Detailed (verbose) | Compact |
| **Identifier detection** | ✅ Stable | △ Some missing |
| **Coordinate format** | `[left,top][right,bottom]` | `{x, y, width, height}` |

#### Why This Project Uses Maestro MCP

1. **Knowledge Sharing with E2E Scenarios**
   - Same selector strategy as YAML scenarios in `~/.maestro/tests/`
   - What works with Maestro CLI also works with Maestro MCP

2. **Consistent Semantics Design**
   - `resource-id` = Flutter `Semantics.identifier`
   - Both E2E and interactive verification can tap with same ID specification

3. **Operation Efficiency**
   - ID-based tap completes in one call (Mobile MCP requires 3 steps: element retrieval → coordinate calculation → tap)
   - Lower total context consumption

4. **YAML Reuse with run_flow**
   - Existing E2E scenarios can be executed directly from MCP

**Conclusion**: While both tools have trade-offs as general-purpose tools, Maestro MCP is optimal for this project focused on accumulating Flutter E2E testing knowledge.

### Self Review
- **Gemini CLI**: Review from external model perspective
- **Claude subagent**: Review from separate context
- **Perspectives**: Code quality, bugs/errors, design patterns
- **Judgment**: PASS / MINOR / FAIL → Self-correction if issues found

## Development Flow

Development flow executed by Claude Code:

```
1. Plan Mode (Design)
   +-- Ask user about unclear points -> Create plan -> Get approval

2. Implementation
   +-- Task management with TodoWrite -> Code generation/editing

3. E2E Testing (Verification)
   +-- Launch app -> UI operations -> Verify results

4. Self Review
   +-- Dual review with Gemini CLI + Claude subagent
   +-- Self-correction if issues found -> Re-review

5. Git Operations
   +-- Commit -> Push -> Request final review from human
```

### Efficient E2E Testing

```
✅ Recommended: hierarchy -> operation -> hierarchy -> ... -> screenshot (final check)
❌ Inefficient: screenshot -> operation -> screenshot -> ...
```

`inspect_view_hierarchy` is lightweight and fast. Use screenshots only when visual confirmation is needed.

### Widget Selection to Implementation Flow

Workflow for modifications starting from a Widget selected in the simulator using `/inspect-widget` command:

```
1. Execute /inspect-widget
   +-- Dart MCP: Enable widget selection mode
   +-- User: Tap to select Widget in simulator

2. Widget Investigation
   +-- Dart MCP: Get widget info with get_selected_widget
   +-- Confirm source code location and properties

3. Modification Request -> Plan Mode
   +-- User: Request like "make it 3-state"
   +-- Claude: Investigate related code -> Create implementation plan

4. Implementation
   +-- Task management with TodoWrite
   +-- Code editing -> Instant reflection with hot_reload

5. Verification
   +-- Maestro MCP: Check state with inspect_view_hierarchy
   +-- Maestro MCP: Operation test with tap_on
   +-- Maestro MCP: Final check with take_screenshot
```

**Example**: Making completion filter 3-state

```
User: (Select filter icon in simulator)
User: "Make it 3-state - All/Completed/Incomplete"

Claude:
  1. get_selected_widget -> Identify Icon at todo_list_screen.dart:92
  2. Plan Mode -> Design CompletionFilter enum
  3. Implementation -> Modify 6 files
  4. Auto-test 3-state cycle with Maestro
  5. Report with screenshots
```

This flow completes **"I want to fix this" -> Select -> Modify -> Verify** in one seamless process.

## Sample App: TODO

TODO app created for verification:

- **State Management**: Riverpod (AsyncNotifier)
- **Persistence**: SharedPreferences
- **Features**:
  - Task CRUD
  - Category classification
  - Due date setting
  - Image attachment
  - Search & filter

## Setup

### Prerequisites

- Flutter SDK
- Android Emulator / iOS Simulator
- [Dart MCP Server](https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server)
- [Maestro MCP](https://github.com/mobile-next/maestro-mcp)

### MCP Configuration

```json
{
  "mcpServers": {
    "dart-mcp": {
      "command": "dart",
      "args": ["run", "dart_mcp_server"],
      "cwd": "/path/to/dart_mcp_server"
    },
    "maestro": {
      "command": "npx",
      "args": ["-y", "@anthropic/maestro-mcp@latest"]
    }
  }
}
```

## Links

- [Maestro - Flutter Testing](https://docs.maestro.dev/platform-support/flutter)
- [Dart MCP Server](https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server)
- [Claude Code](https://claude.ai/code)

## License

MIT
