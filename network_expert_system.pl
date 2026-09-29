% Computer Network Troubleshooting Expert System
% Assignment 2
% SWI-Prolog
:- dynamic answer/2.
:- dynamic selected_connection/1.
start :-
    reset_answers,
    banner,
    choose_connection,
    ( diagnose(Id, Diagnosis, Recommendation) ->
        show_result(Id, Diagnosis, Recommendation)
    ;
        writeln('No specific rule matched the supplied answers.'),
        writeln('Recommendation: collect more information or consult a network administrator.')
    ),
    nl,
    writeln('Type start. to run another diagnosis.'),
    !.
banner :-
    nl,
    writeln('======================================================'),
    writeln(' COMPUTER NETWORK TROUBLESHOOTING EXPERT SYSTEM'),
    writeln('======================================================'),
    writeln('Answer questions with yes. or no. (include the period).'),
    nl.
choose_connection :-
    writeln('Select the main connection type:'),
    writeln('  1. Wi-Fi'),
    writeln('  2. Ethernet'),
    write('Enter 1 or 2: '),
    read(X),
    ( X == 1 -> assertz(selected_connection(wifi))
    ; X == 2 -> assertz(selected_connection(ethernet))
    ; writeln('Invalid choice. Please enter 1 or 2.'), choose_connection
    ).
reset_answers :-
    retractall(answer(_,_)),
    retractall(selected_connection(_)).
check(Key, Expected) :-
    answer(Key, Value), !,
    Value == Expected.
check(Key, Expected) :-
    ask(Key, Value),
    Value == Expected.
ask(Key, Value) :-
    question(Key, Text),
    format('~w (yes/no): ', [Text]),
    read(Input),
    normalize_answer(Input, Value),
    assertz(answer(Key, Value)).

normalize_answer(yes, yes) :- !.
normalize_answer(y, yes) :- !.
normalize_answer(no, no) :- !.
normalize_answer(n, no) :- !.
normalize_answer(_, Value) :-
    writeln('Please answer yes. or no.'),
    write('Answer: '),
    read(Input),
    normalize_answer(Input, Value).
satisfy(conn(Type)) :- selected_connection(Type).
satisfy(yes(Key)) :- check(Key, yes).
satisfy(no(Key)) :- check(Key, no).

satisfy_all([]).
satisfy_all([C|Cs]) :- satisfy(C), satisfy_all(Cs).
rule_priority([r01,r02,r03,r04,r05,r08,r09,r10,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23,r24,r07,r12,r06,r11,r25]).

diagnose(Id, Diagnosis, Recommendation) :-
    rule_priority(Order),
    member(Id, Order),
    rule(Id, Conditions, Diagnosis, Recommendation),
    satisfy_all(Conditions),
    !.
show_result(Id, Diagnosis, Recommendation) :-
    nl,
    writeln('------------------------------------------------------'),
    format('Matched Rule: ~w~n', [Id]),
    format('Diagnosis: ~w~n', [Diagnosis]),
    format('Recommendation: ~w~n', [Recommendation]),
    writeln('------------------------------------------------------').
question(wifi_enabled, 'Is Wi-Fi turned on?').
question(airplane_mode, 'Is Airplane mode enabled?').
question(wifi_connected, 'Is the device currently connected to the Wi-Fi network?').
question(expected_wifi_visible, 'Can you see the expected Wi-Fi network in the available network list?').
question(connection_attempt_fails, 'Does the connection attempt fail even though the network is visible?').
question(internet_available, 'Can this device access the Internet normally?').
question(other_device_works, 'Can another device use the same network successfully?').
question(router_reachable, 'Can the device reach/ping the local router or default gateway?').
question(ethernet_to_modem_works, 'If tested, does a direct Ethernet connection to the modem/network work?').
question(cable_secure, 'Is the Ethernet cable securely connected at both ends?').
question(alternate_cable_works, 'Does another known-good Ethernet cable work?').
question(ethernet_connected, 'Does Windows/macOS show the Ethernet connection as connected?').
question(wifi_same_device_works, 'Does Wi-Fi work on the same device?').
question(router_restarted, 'Have the modem/router been restarted during this troubleshooting attempt?').
question(valid_ip, 'Does the device have a valid IP address, subnet mask, and default gateway for this network?').
question(dynamic_ip, 'Is the device configured to obtain its IP address automatically (DHCP)?').
question(local_ip_ping, 'Can the device ping its own local IP address?').
question(gateway_reachable, 'Can the device reach/ping its configured default gateway?').
question(dns_config_correct, 'Are the configured DNS server addresses correct for the network?').
question(dns_server_reachable, 'Can the device reach at least one configured DNS server by IP address?').
question(dns_query_works, 'Does an nslookup/DNS query for a known name succeed?').
question(ip_internet_works, 'Can the device reach an Internet destination by IP address?').
question(name_resolution_issue, 'Is the current problem specifically related to resolving host/domain names?').
question(dns_cache_flushed, 'Has the DNS resolver cache already been flushed during this troubleshooting attempt?').
question(hostname_access_works, 'Can the device access Internet services using normal host/domain names?').
question(specific_app_only_fails, 'Is the problem limited to one application or one network service/port?').
question(vpn_security_active, 'Is a VPN or network/security software currently active?').
question(common_steps_failed, 'Have the common connection, router, IP, and DNS troubleshooting steps already failed?').
question(problem_after_update, 'Did the network problem start after a recent system/driver update?').
question(network_reset_done, 'Has a network reset already been performed as a final troubleshooting step?').

% ---------------- Knowledge Base: 25 sourced rules ----------------
% R01: Wi-Fi disabled | Sources: [1]
rule(r01, [conn(wifi), no(wifi_enabled)], 'Wi-Fi is disabled.', 'Turn on Wi-Fi and try to connect again.').

% R02: Airplane mode enabled | Sources: [1]
rule(r02, [conn(wifi), yes(wifi_enabled), yes(airplane_mode)], 'Airplane mode is preventing normal wireless communication.', 'Turn off Airplane mode, then reconnect to Wi-Fi.').

% R03: Expected Wi-Fi network not visible | Sources: [1]
rule(r03, [conn(wifi), yes(wifi_enabled), no(airplane_mode), no(wifi_connected), no(expected_wifi_visible)], 'The expected Wi-Fi network is not currently visible.', 'Refresh the Wi-Fi list, move closer to the access point, and try the other supported Wi-Fi band if available.').

% R04: Known Wi-Fi network connection fails | Sources: [1]
rule(r04, [conn(wifi), yes(wifi_enabled), no(airplane_mode), no(wifi_connected), yes(expected_wifi_visible), yes(connection_attempt_fails)], 'The device can see the Wi-Fi network but cannot connect successfully.', 'Forget the saved Wi-Fi network and reconnect using the correct credentials.').

% R05: Wi-Fi network not selected | Sources: [1]
rule(r05, [conn(wifi), yes(wifi_enabled), no(airplane_mode), no(wifi_connected), yes(expected_wifi_visible), no(connection_attempt_fails)], 'The device is not connected to an available Wi-Fi network.', 'Select the correct Wi-Fi network and connect to it.').

% R06: Problem isolated to current device | Sources: [1], [2]
rule(r06, [no(internet_available), yes(other_device_works)], 'The connectivity problem is likely local to the current device.', 'Continue troubleshooting the device network configuration, adapter, VPN/security software, and drivers.').

% R07: Likely Wi-Fi router problem | Sources: [1], [5]
rule(r07, [conn(wifi), yes(wifi_connected), no(internet_available), no(router_reachable), yes(ethernet_to_modem_works)], 'The Wi-Fi router or wireless path is a likely source of the problem.', 'Restart the router, check router firmware/settings, and retest Wi-Fi.').

% R08: Ethernet cable not secure | Sources: [2]
rule(r08, [conn(ethernet), no(cable_secure)], 'The Ethernet cable connection is not secure.', 'Reconnect the Ethernet cable firmly at both the computer and router/switch.').

% R09: Possible faulty Ethernet cable | Sources: [2]
rule(r09, [conn(ethernet), yes(cable_secure), yes(alternate_cable_works)], 'The original Ethernet cable is likely faulty.', 'Replace the original Ethernet cable.').

% R10: Ethernet path problem | Sources: [2]
rule(r10, [conn(ethernet), yes(cable_secure), no(ethernet_connected), yes(wifi_same_device_works)], 'The problem is likely specific to the Ethernet path or adapter.', 'Check the Ethernet port, adapter status, cable, and driver.').

% R11: Possible router/ISP/network-side problem | Sources: [1], [2], [5]
rule(r11, [no(internet_available), no(other_device_works)], 'The problem may be with the router, modem, ISP, or wider network.', 'Restart network equipment and check for an ISP/service outage.').

% R12: Router/modem restart recommended | Sources: [1], [2], [5]
rule(r12, [no(internet_available), no(router_restarted)], 'The router/modem has not yet been restarted during troubleshooting.', 'Restart the modem/router, wait for it to fully reconnect, and test again.').

% R13: Dynamic IP configuration problem | Sources: [4], [5]
rule(r13, [no(valid_ip), yes(dynamic_ip)], 'The device does not have a valid dynamically assigned TCP/IP configuration.', 'Renew the DHCP lease / IP configuration and test again.').

% R14: Static IP configuration problem | Sources: [4]
rule(r14, [no(valid_ip), no(dynamic_ip)], 'The static TCP/IP configuration is invalid or incomplete.', 'Correct the IP address, subnet mask, default gateway, and DNS settings for the network.').

% R15: Local TCP/IP stack/interface problem | Sources: [3]
rule(r15, [yes(valid_ip), no(local_ip_ping)], 'The local TCP/IP stack or network interface may not be working correctly.', 'Check the interface/adapter state and reset the local TCP/IP stack if appropriate.').

% R16: Default gateway/local network problem | Sources: [3], [4]
rule(r16, [yes(valid_ip), yes(local_ip_ping), no(gateway_reachable)], 'The default gateway or local network path cannot be reached.', 'Check the gateway address, local link, router/switch, VLAN, and related local network configuration.').

% R17: Incorrect DNS configuration | Sources: [4], [6]
rule(r17, [yes(valid_ip), yes(gateway_reachable), no(dns_config_correct)], 'The configured DNS server information appears incorrect.', 'Configure the correct DNS server address(es) for the network.').

% R18: DNS server unreachable | Sources: [4], [6]
rule(r18, [yes(valid_ip), yes(gateway_reachable), yes(dns_config_correct), no(dns_server_reachable)], 'The client cannot reach the configured DNS server.', 'Troubleshoot network connectivity between the client and DNS server and verify firewall/path availability.').

% R19: DNS service/query problem | Sources: [4], [6]
rule(r19, [yes(dns_server_reachable), no(dns_query_works), yes(ip_internet_works)], 'Basic IP connectivity works, but DNS queries are failing.', 'Check DNS server operation/configuration and test name resolution with nslookup.').

% R20: DNS cache issue | Sources: [1], [2], [4]
rule(r20, [yes(name_resolution_issue), no(dns_cache_flushed)], 'A stale or negative DNS cache entry may be contributing to the name-resolution problem.', 'Flush the DNS resolver cache and test the name again.').

% R21: DNS/name-resolution problem | Sources: [4], [6]
rule(r21, [yes(ip_internet_works), no(hostname_access_works)], 'Internet connectivity by IP works, but hostname access fails.', 'Check DNS configuration, DNS server reachability, and name-resolution tests.').

% R22: Application/firewall-specific problem | Sources: [1], [3]
rule(r22, [yes(internet_available), yes(specific_app_only_fails)], 'The network is generally working, but a specific application/service is failing.', 'Check the application, required destination port, and firewall/security rules.').

% R23: Possible VPN/security-software interference | Sources: [5]
rule(r23, [no(internet_available), yes(vpn_security_active)], 'VPN or security software may be interfering with network access.', 'Temporarily troubleshoot the VPN/security network component according to its documentation and retest connectivity.').

% R24: Possible network adapter driver problem | Sources: [1], [2]
rule(r24, [yes(common_steps_failed), yes(problem_after_update)], 'A network adapter driver problem is possible, especially after a recent update.', 'Reinstall or update the network adapter driver using the device manufacturer guidance.').

% R25: Network reset as final recovery step | Sources: [1], [2]
rule(r25, [yes(common_steps_failed), no(network_reset_done)], 'Common troubleshooting steps have not resolved the problem.', 'Use network reset only as a final software troubleshooting step, then reconfigure required networking software if necessary.').

