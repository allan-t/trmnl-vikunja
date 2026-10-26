# 05: Empty and error states

**What to build:** When there are no open Tasks the screen shows "No open tasks". When the Vikunja request fails (bad token, server down) it shows a short error message instead of a blank or broken screen.

**Blocked by:** 01 Walking skeleton

**Status:** ready-for-agent

- [ ] Empty Task response renders "No open tasks"
- [ ] Failed or unauthorised response renders a short error message
- [ ] Fixture-render tests cover both states
