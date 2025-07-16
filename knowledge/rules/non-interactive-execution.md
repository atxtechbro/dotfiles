# Non-Interactive Execution Only

Claude can't type. Period. No interactive commands. Ever.

**What breaks**: `claude setup-token`, `git commit` (without -m), `npm install` (without -y)
**What works**: `claude -p setup-token`, `git commit -m "msg"`, `npm install -y`

Stop trying to be clever. Claude IS the interactive session. It can't nest another one.