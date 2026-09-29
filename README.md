# Computer Network Troubleshooting Expert System

A command-line expert system written in **SWI-Prolog** for diagnosing common Wi-Fi and Ethernet problems. It asks questions about your connection, checks your answers against 25 troubleshooting rules, and displays the first matching diagnosis with a recommended action.

The program is contained in [`network_expert_system.pl`](network_expert_system.pl) and is identified in its source as Assignment 2.

## Requirements

- SWI-Prolog installed on your computer.
- A terminal or the SWI-Prolog application.

No additional Prolog libraries or packages are required.

## Running the program

Open a terminal in the folder containing `network_expert_system.pl` and run:

```sh
swipl -s network_expert_system.pl
```

At the Prolog prompt, enter:

```prolog
start.
```

Alternatively, open SWI-Prolog, change to the project folder, and load the file before starting:

```prolog
['network_expert_system.pl'].
start.
```

If the terminal cannot find `swipl`, use the SWI-Prolog application or add its executable directory to your system's `PATH`.

## Answering questions

1. Select your main connection: enter `1.` for Wi-Fi or `2.` for Ethernet.
2. Answer each question with `yes.` or `no.`. The shortcuts `y.` and `n.` also work.
3. Read the matched rule ID, diagnosis, and recommendation.
4. Apply the relevant troubleshooting step yourself, then enter `start.` to begin a fresh diagnosis if needed.

**Include the final period in every input**, including the connection number. The program reads Prolog terms, so press Enter after the period. Use lowercase answers. Unrecognized choices or answers are requested again; malformed Prolog syntax can produce a Prolog error.

To exit SWI-Prolog, enter:

```prolog
halt.
```

## Example session

This example selects Wi-Fi and reports that Wi-Fi is turned off:

```text
?- start.

======================================================
 COMPUTER NETWORK TROUBLESHOOTING EXPERT SYSTEM
======================================================
Answer questions with yes. or no. (include the period).

Select the main connection type:
  1. Wi-Fi
  2. Ethernet
Enter 1 or 2: 1.
Is Wi-Fi turned on? (yes/no): no.

------------------------------------------------------
Matched Rule: r01
Diagnosis: Wi-Fi is disabled.
Recommendation: Turn on Wi-Fi and try to connect again.
------------------------------------------------------

Type start. to run another diagnosis.
```

## Problems covered

| Area | Examples |
| --- | --- |
| Wi-Fi | Wi-Fi disabled, Airplane mode enabled, missing network, failed connection, network not selected |
| Ethernet | Loose cable, faulty cable, Ethernet path or adapter problem |
| Router and wider network | Unreachable router, restart needed, possible modem or ISP problem |
| IP configuration | Invalid DHCP or static settings, local TCP/IP or interface problem, unreachable gateway |
| DNS | Incorrect settings, unreachable DNS server, failed queries, cache issues, hostname access failure |
| Applications and recovery | Application-specific failure, VPN/security interference, possible driver problem, network reset |

## How it works

The system uses a rule-based knowledge base and Prolog's goal evaluation:

1. `start/0` clears answers from the previous session and asks for the connection type.
2. `diagnose/3` checks rules in the order defined by `rule_priority/1`.
3. Each rule contains conditions such as `conn(wifi)`, `yes(valid_ip)`, or `no(internet_available)`.
4. Conditions prompt for answers only when needed. Answers are stored in `answer/2`, so the same question key is not asked again during that session.
5. The first rule whose conditions all succeed supplies the diagnosis and recommendation. The program then stops searching.

The priority order is explicitly defined rather than strictly numerical:

```text
r01, r02, r03, r04, r05, r08, r09, r10,
r13, r14, r15, r16, r17, r18, r19, r20,
r21, r22, r23, r24, r07, r12, r06, r11, r25
```

If no rule matches, the program recommends collecting more information or consulting a network administrator.

## Main predicates

The `/N` notation gives the number of arguments a predicate takes.

| Predicate | Purpose |
| --- | --- |
| `start/0` | Runs a new troubleshooting session |
| `reset_answers/0` | Clears stored answers and the selected connection |
| `choose_connection/0` | Reads the Wi-Fi or Ethernet selection |
| `ask/2` | Prompts for and stores an answer |
| `check/2` | Retrieves or asks for an answer, then checks its expected value |
| `satisfy_all/1` | Checks all conditions for a rule |
| `diagnose/3` | Finds the first matching rule and its result |
| `show_result/3` | Displays the rule ID, diagnosis, and recommendation |
| `question/2` | Maps question keys to readable prompts |
| `rule/4` | Defines a rule ID, conditions, diagnosis, and recommendation |
| `rule_priority/1` | Defines the order in which rules are evaluated |

## Adding a rule

Add any new question keys using `question/2`, then define a rule using this structure:

```prolog
rule(r26,
     [conn(wifi), yes(wifi_connected), no(internet_available)],
     'Your diagnosis text.',
     'Your recommended action.').
```

Add the new rule ID to `rule_priority/1` at the appropriate position. Placement matters: an earlier matching rule prevents later rules from being selected. Reload the file in SWI-Prolog after editing it.

## Limitations and source notes

- The program relies entirely on your answers. It does not run ping or DNS tests, inspect settings, or make changes to your computer.
- There is no `unknown` or `not tested` answer. Some questions require you to perform a check before answering accurately.
- Only one diagnosis is returned per session, even when several rules could match.
- Diagnoses are troubleshooting suggestions based on a fixed knowledge base, rather than confirmation of a fault.
- Source comments cite references `[1]` through `[6]`, but the supplied file does not include their bibliography or URLs.
