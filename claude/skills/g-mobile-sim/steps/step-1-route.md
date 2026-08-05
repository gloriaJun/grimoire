# Step 1: Route

Fix the path before booting anything. A wrong path costs a 60 s boot and still
ends in a dead end.

## 1. Establish the goal

Goal stated in the request -> use it. Otherwise ask once, offering: layout
check, web page on the real engine, tap/type/scroll scenario, LINE in-app
webview.

## 2. Check tool availability

- Interaction beyond opening a URL needs the mcp-mobile MCP server, which is
  project-scoped (declared in a repository `.mcp.json`), not global. Call
  `mobile_list_available_devices` once. Tool missing or erroring -> report that
  interaction is unavailable in this session and offer two options: the
  simctl/adb-only path (open URL plus screenshot), or rerunning from a
  repository whose `.mcp.json` provides mcp-mobile. Do not boot until the user
  picks.
- An empty device list from that call is normal at this point: mcp-mobile only
  reports devices that are already running.
- Layout-only goals never boot a device. Delegate to playwright MCP viewport
  emulation and stop.

## 3. Map goal to path

| Goal | Path | Interaction |
|---|---|---|
| Layout or responsive only | playwright MCP, no boot | viewport only |
| Web page on the real engine | iOS simulator + simctl | open URL, screenshot |
| Tap, type, scroll, swipe | Android emulator + mcp-mobile | full |
| LINE in-app webview | device with `line=yes`; full interaction needs Android | per platform |

iOS combined with tap, type, or scroll: state that WebDriverAgent is not set up
on this machine (details in `references/paths.md`), then offer Android instead
or the simctl-only path. Never boot an iOS simulator for an interaction goal
before the user chooses.

## 4. Collect boot inputs

- Android against a host dev server needs the reverse port. Not stated in the
  request -> ask once for the port number. Public URL only -> omit the argument.
- iOS shares the host `localhost`, so it takes no port argument.

Then read `steps/step-2-boot.md`.
