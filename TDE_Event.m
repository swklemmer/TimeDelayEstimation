function [SeqControl, Event] = TDE_Event(P)
% Specify structure arrays for the Event Sequence.

% Specify the Sequence of Events
    %   1 event for TPC profile initialization
    %   1 event for sequencer syncronization
    % + 1 event for reference b-mode and push TPC transition
    % + 1 event for push sequence and imaging TPC transition
    % + N-1 events for each other tracking b-mode
    % + 1 event for data transfer
    % + 2 events for reconstruction
    % + 1 events for last b-mode display
    % + 1 event for displacement processing
    % + 1 event to jump back to beginning

Event = repmat(struct('info', 0, ...
    'tx', 0, ...
    'rcv', 0, ...
    'recon', 0, ...
    'process', 0, ...
    'seqControl', 0), ...
    1, P.bmode_adq + 9);

% Event and SC count
n = 1;
nsc = 1;

% #1: TPC push profile transition
Event(n) = struct('info', 'TPC push profile transition', ...
    'tx', 0, ...
    'rcv', 0, ...
    'recon', 0, ...
    'process', 0, ...
    'seqControl', nsc + [0, 1]);

    % Set push TPC profile
    SeqControl(nsc) = struct( ...
        'command', 'setTPCProfile', ...
        'argument', 5, ...
        'condition', 'immediate');
    
    % Wait 5m for TPC transtion
    SeqControl(nsc + 1) = struct( ...
    'command', 'noop', ...
    'argument', floor(5e-3 / 0.2e-6), ...
    'condition', '');

    n = n + 1; nsc = nsc + 2;

% #2: Sync
Event(n) = struct('info', 'Sync', ...
    'tx', 0, ...
    'rcv', 0, ...
    'recon', 0, ...
    'process', 0, ...
    'seqControl', nsc);
 
    % Sync hardware and software sequencers
    SeqControl(nsc) = struct( ...
    'command', 'sync', ...
    'argument', 0, ...
    'condition', '');

    n = n + 1; nsc = nsc + 1;
    
% #3: Reference B-mode
Event(n) = struct('info', 'Reference B-mode', ...
    'tx', 1, ...
    'rcv', 1, ...
    'recon', 0, ...
    'process', 0, ...
    'seqControl', nsc);
 
    % Wait 10u until push
    SeqControl(nsc) = struct( ...
    'command', 'noop', ...
    'argument', floor(10e-6 / 0.2e-6), ...
    'condition', '');

    n = n + 1; nsc = nsc + 1;

% #4: Push transmit 
Event(n) = struct('info', 'Push transmit', ...
    'tx', 2, ...
    'rcv', 0, ...
    'recon', 0, ...
    'process', 0, ...
    'seqControl', 0);

    n = n + 1;

% # 5 -> P.bmode_adq + 2: Tracking b-mode
for i = 1:(P.bmode_adq-2)

    Event(n) = struct('info', 'Tracking b-mode', ...
    'tx', 1, ...
    'rcv', i + 1, ...
    'recon', 0, ...
    'process', 0, ...
    'seqControl', nsc);

    % Wait P.bmode_dly [usec] for next adq
    SeqControl(nsc) = struct( ...
        'command', 'timeToNextAcq', ...
        'argument', P.bmode_dly, ...
        'condition', '');

    n = n + 1; nsc = nsc + 1;
end

% # P.bmode_adq + 3: Last b-mode
Event(n) = struct('info', 'Last B-mode', ...
    'tx', 1, ...
    'rcv', P.bmode_adq, ...
    'recon', 0, ...
    'process', 0, ...
    'seqControl', 0);

    n = n + 1;

% # P.bmode_adq + 4: Transfer adquisitions to host
Event(n) = struct('info', 'Transfer adquisitions to host', ...
    'tx', 0, ...
    'rcv', 0, ...
    'recon', 0, ...
    'process', 0, ...
    'seqControl', nsc);

    % Transfer to Host
    SeqControl(nsc) = struct( ...
        'command', 'transferToHost', ...
        'argument', 0, ...
        'condition', '');

    n = n + 1; nsc = nsc + 1;

% # P.bmode_adq + 5: Reconstruct into Interbuffer
Event(n) = struct('info', 'Reconstruct into Interbuffer', ...
    'tx', 0, ...
    'rcv', 0, ...
    'recon', 1, ...
    'process', 0, ...
    'seqControl', nsc);

    % Wait for transfer to be completed
    SeqControl(nsc) = struct( ...
        'command', 'waitForTransferComplete', ...
        'argument', nsc - 1, ...
        'condition', '');
    
   n = n + 1; nsc = nsc + 1;

% # P.bmode_adq + 6: Reconstruct into Imagebuffer
Event(n) = struct('info', 'Reconstruct into Imagebuffer', ...
    'tx', 0, ...
    'rcv', 0, ...
    'recon', 2, ...
    'process', 0, ...
    'seqControl', 0);
    
   n = n + 1;

% # P.bmode_adq + 7: Show last B-mode
Event(n) = struct('info', 'Show last B-mode', ...
    'tx', 0, ...
    'rcv', 0, ...
    'recon', 0, ...
    'process', 1, ...
    'seqControl', 0);

    n = n + 1;

% # P.bmode_adq + 8: Process displacement estimation

Event(n) = struct('info', 'Process displacement estimation', ...
    'tx', 0, ...
    'rcv', 0, ...
    'recon', 0, ...
    'process', 2, ...
    'seqControl', 0);

    n = n + 1;

% # P.bmode_adq + 9: Jump back to Event 2 and go back to Matlab
Event(n) = struct('info', 'Jump back to Event 2', ...
    'tx', 0, ...
    'rcv', 0, ...
    'recon', 0, ...
    'process', 0, ...
    'seqControl', nsc); % don't jump nack for debugging

    % Jump back to Event 2
%     SeqControl(nsc) = struct( ...
%         'command', 'jump', ...
%         'argument', 2, ...
%         'condition', 'exitAfterJump');

    % Return to Matlab
    SeqControl(nsc) = struct( ...
        'command', 'returnToMatlab', ...
        'argument', 0, ...
        'condition', '');

end
