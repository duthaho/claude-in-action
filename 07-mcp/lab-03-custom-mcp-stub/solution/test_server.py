"""Drive server.py over stdin/stdout and assert protocol-level behavior."""
from __future__ import annotations

import json
import subprocess
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).parent
SERVER = HERE / "server.py"


def rpc(messages: list[dict]) -> list[dict]:
    payload = "\n".join(json.dumps(m) for m in messages) + "\n"
    proc = subprocess.run(
        [sys.executable, str(SERVER)],
        input=payload,
        capture_output=True,
        text=True,
        timeout=10,
    )
    lines = [line for line in proc.stdout.splitlines() if line.strip()]
    return [json.loads(line) for line in lines]


class TestInitialize(unittest.TestCase):
    def test_initialize_returns_capabilities_and_info(self):
        resp = rpc([
            {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}}},
        ])[0]
        self.assertEqual(resp["jsonrpc"], "2.0")
        self.assertEqual(resp["id"], 1)
        self.assertIn("result", resp)
        result = resp["result"]
        self.assertIn("protocolVersion", result)
        self.assertIn("capabilities", result)
        self.assertIn("tools", result["capabilities"])
        self.assertIn("serverInfo", result)
        self.assertIn("name", result["serverInfo"])


class TestToolsList(unittest.TestCase):
    def test_tools_list_has_get_quote_and_echo(self):
        resp = rpc([
            {"jsonrpc": "2.0", "id": 2, "method": "tools/list"},
        ])[0]
        self.assertIn("result", resp)
        tools = resp["result"]["tools"]
        names = {t["name"] for t in tools}
        self.assertEqual(names, {"get_quote", "echo"})
        for tool in tools:
            self.assertIn("description", tool)
            self.assertIn("inputSchema", tool)
            self.assertEqual(tool["inputSchema"]["type"], "object")


class TestToolsCall(unittest.TestCase):
    def test_echo_returns_text_content(self):
        resp = rpc([
            {
                "jsonrpc": "2.0",
                "id": 3,
                "method": "tools/call",
                "params": {"name": "echo", "arguments": {"text": "hi there"}},
            },
        ])[0]
        self.assertIn("result", resp)
        content = resp["result"]["content"]
        self.assertEqual(len(content), 1)
        self.assertEqual(content[0]["type"], "text")
        self.assertEqual(content[0]["text"], "hi there")

    def test_get_quote_returns_non_empty_text(self):
        resp = rpc([
            {
                "jsonrpc": "2.0",
                "id": 4,
                "method": "tools/call",
                "params": {"name": "get_quote", "arguments": {}},
            },
        ])[0]
        self.assertIn("result", resp)
        content = resp["result"]["content"]
        self.assertEqual(content[0]["type"], "text")
        self.assertTrue(content[0]["text"])


if __name__ == "__main__":
    unittest.main()
