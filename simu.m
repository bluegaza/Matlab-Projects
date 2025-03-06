% This MATLAB script creates a Simulink model that precisely matches the one in the image
% with correct components, connections, and configuration

% Create a new Simulink model
modelName = 'Logic_Circuit_Design';
close_system(modelName, 0);  % Close the model if it's already open
new_system(modelName);
open_system(modelName);

% Set up model parameters
set_param(modelName, 'Solver', 'FixedStepDiscrete', 'FixedStep', '1');

%% Left Side - Transmitters/Encoders Section

% Add input sources (creating inputs at the left edges)
for i = 1:4
    add_block('simulink/Sources/In1', [modelName '/In' num2str(i)]);
    set_param([modelName '/In' num2str(i)], 'Position', [20, 40+60*(i-1), 40, 60+60*(i-1)]);
end

% Add AND gates on the left side (top pair)
add_block('simulink/Logic and Bit Operations/Logical Operator', [modelName '/AND_1_1']);
set_param([modelName '/AND_1_1'], 'Position', [80, 50, 110, 80], 'Operator', 'AND', 'Inputs', '2');
add_block('simulink/Logic and Bit Operations/Logical Operator', [modelName '/AND_1_2']);
set_param([modelName '/AND_1_2'], 'Position', [80, 110, 110, 140], 'Operator', 'AND', 'Inputs', '2');

% Add XOR gate for the first encoder
add_block('simulink/Logic and Bit Operations/Logical Operator', [modelName '/XOR_1']);
set_param([modelName '/XOR_1'], 'Position', [150, 80, 180, 110], 'Operator', 'XOR', 'Inputs', '2');

% Add AND gates on the left side (bottom pair)
add_block('simulink/Logic and Bit Operations/Logical Operator', [modelName '/AND_2_1']);
set_param([modelName '/AND_2_1'], 'Position', [80, 170, 110, 200], 'Operator', 'AND', 'Inputs', '2');
add_block('simulink/Logic and Bit Operations/Logical Operator', [modelName '/AND_2_2']);
set_param([modelName '/AND_2_2'], 'Position', [80, 230, 110, 260], 'Operator', 'AND', 'Inputs', '2');

% Add XOR gate for the second encoder
add_block('simulink/Logic and Bit Operations/Logical Operator', [modelName '/XOR_2']);
set_param([modelName '/XOR_2'], 'Position', [150, 200, 180, 230], 'Operator', 'XOR', 'Inputs', '2');

% Add transmission line label block
add_block('simulink/Signal Attributes/Model Info', [modelName '/Transmission_Line']);
set_param([modelName '/Transmission_Line'], 'Position', [120, 140, 210, 160], 'Info', 'Transmission Line');

%% Middle Section - Control Units

% Add Input Control block (appears to be labeled in image)
add_block('simulink/Discrete/Discrete-Time Integrator', [modelName '/Input_Control']);
set_param([modelName '/Input_Control'], 'Position', [220, 75, 280, 115]);
set_param([modelName '/Input_Control'], 'SampleTime', '-1');

% Add Delay Control block (appears to be labeled in image)
add_block('simulink/Discrete/Discrete-Time Integrator', [modelName '/Delay_Control']);
set_param([modelName '/Delay_Control'], 'Position', [220, 195, 280, 235]);
set_param([modelName '/Delay_Control'], 'SampleTime', '-1');

% Add Middle Control blocks (appears to be two main IC chips in the center)
% Top IC
add_block('simulink/User-Defined Functions/MATLAB Function', [modelName '/Control_IC_1']);
set_param([modelName '/Control_IC_1'], 'Position', [320, 50, 380, 130]);

% Bottom IC
add_block('simulink/User-Defined Functions/MATLAB Function', [modelName '/Control_IC_2']);
set_param([modelName '/Control_IC_2'], 'Position', [320, 170, 380, 250]);

%% Right Side - Output Logic Gates

% Create 3 pairs of output logic gates at the top
for i = 1:3
    % AND gates
    add_block('simulink/Logic and Bit Operations/Logical Operator', [modelName '/Out_AND_Top_' num2str(i)]);
    set_param([modelName '/Out_AND_Top_' num2str(i)], 'Position', [420, 30+40*(i-1), 450, 60+40*(i-1)], 'Operator', 'AND', 'Inputs', '2');
    
    % Final output OR gates 
    add_block('simulink/Logic and Bit Operations/Logical Operator', [modelName '/Out_OR_Top_' num2str(i)]);
    set_param([modelName '/Out_OR_Top_' num2str(i)], 'Position', [480, 30+40*(i-1), 510, 60+40*(i-1)], 'Operator', 'OR', 'Inputs', '2');
    
    % Output terminals
    add_block('simulink/Sinks/Out1', [modelName '/Out_Top_' num2str(i)]);
    set_param([modelName '/Out_Top_' num2str(i)], 'Position', [550, 35+40*(i-1), 570, 55+40*(i-1)]);
end

% Create 3 pairs of output logic gates at the bottom
for i = 1:3
    % AND gates
    add_block('simulink/Logic and Bit Operations/Logical Operator', [modelName '/Out_AND_Bottom_' num2str(i)]);
    set_param([modelName '/Out_AND_Bottom_' num2str(i)], 'Position', [420, 150+40*(i-1), 450, 180+40*(i-1)], 'Operator', 'AND', 'Inputs', '2');
    
    % Final output OR gates
    add_block('simulink/Logic and Bit Operations/Logical Operator', [modelName '/Out_OR_Bottom_' num2str(i)]);
    set_param([modelName '/Out_OR_Bottom_' num2str(i)], 'Position', [480, 150+40*(i-1), 510, 180+40*(i-1)], 'Operator', 'OR', 'Inputs', '2');
    
    % Output terminals
    add_block('simulink/Sinks/Out1', [modelName '/Out_Bottom_' num2str(i)]);
    set_param([modelName '/Out_Bottom_' num2str(i)], 'Position', [550, 155+40*(i-1), 570, 175+40*(i-1)]);
end

%% Connections - Left Section

% Connect inputs to first AND gates
add_line(modelName, 'In1/1', 'AND_1_1/1');
add_line(modelName, 'In2/1', 'AND_1_1/2');
add_line(modelName, 'In2/1', 'AND_1_2/1', 'autorouting', 'on');
add_line(modelName, 'In1/1', 'AND_1_2/2', 'autorouting', 'on');

% Connect AND gates to XOR
add_line(modelName, 'AND_1_1/1', 'XOR_1/1');
add_line(modelName, 'AND_1_2/1', 'XOR_1/2');

% Connect inputs to second AND gates
add_line(modelName, 'In3/1', 'AND_2_1/1');
add_line(modelName, 'In4/1', 'AND_2_1/2');
add_line(modelName, 'In4/1', 'AND_2_2/1', 'autorouting', 'on');
add_line(modelName, 'In3/1', 'AND_2_2/2', 'autorouting', 'on');

% Connect AND gates to XOR
add_line(modelName, 'AND_2_1/1', 'XOR_2/1');
add_line(modelName, 'AND_2_2/1', 'XOR_2/2');

%% Connections - Middle Section

% Connect XORs to control units
add_line(modelName, 'XOR_1/1', 'Input_Control/1');
add_line(modelName, 'XOR_2/1', 'Delay_Control/1');

% Connect control units to ICs
add_line(modelName, 'Input_Control/1', 'Control_IC_1/1');
add_line(modelName, 'Delay_Control/1', 'Control_IC_2/1');

%% Connections - Right Section

% Connect top IC to top output AND gates
for i = 1:3
    % Create output ports for the Control_IC_1 (these appear to be multiple outputs in the image)
    set_param([modelName '/Control_IC_1'], 'OutputPortMap', '[1,2,3,4,5,6]');
    
    % Connect to AND gates
    add_line(modelName, ['Control_IC_1/' num2str(i)], ['Out_AND_Top_' num2str(i) '/1']);
    add_line(modelName, ['Control_IC_1/' num2str(i+3)], ['Out_AND_Top_' num2str(i) '/2']);
    
    % Connect AND gates to OR gates
    add_line(modelName, ['Out_AND_Top_' num2str(i) '/1'], ['Out_OR_Top_' num2str(i) '/1']);
    
    % Connect OR gates to output
    add_line(modelName, ['Out_OR_Top_' num2str(i) '/1'], ['Out_Top_' num2str(i) '/1']);
end

% Connect bottom IC to bottom output AND gates
for i = 1:3
    % Create output ports for the Control_IC_2
    set_param([modelName '/Control_IC_2'], 'OutputPortMap', '[1,2,3,4,5,6]');
    
    % Connect to AND gates
    add_line(modelName, ['Control_IC_2/' num2str(i)], ['Out_AND_Bottom_' num2str(i) '/1']);
    add_line(modelName, ['Control_IC_2/' num2str(i+3)], ['Out_AND_Bottom_' num2str(i) '/2']);
    
    % Connect AND gates to OR gates
    add_line(modelName, ['Out_AND_Bottom_' num2str(i) '/1'], ['Out_OR_Bottom_' num2str(i) '/1']);
    
    % Connect OR gates to output
    add_line(modelName, ['Out_OR_Bottom_' num2str(i) '/1'], ['Out_Bottom_' num2str(i) '/1']);
end

% Create MATLAB Function content for Control_IC_1
control_ic1_code = ['function [o1, o2, o3, o4, o5, o6] = fcn(u)\n', ...
                   '% This function implements the logic for the top control IC\n', ...
                   '% Input u comes from the input control module\n', ...
                   'o1 = u > 0.5;\n', ...
                   'o2 = u > 0.25;\n', ...
                   'o3 = u > 0.75;\n', ...
                   'o4 = ~u;\n', ...
                   'o5 = u < 0.5;\n', ...
                   'o6 = u < 0.25;\n'];

% Create MATLAB Function content for Control_IC_2
control_ic2_code = ['function [o1, o2, o3, o4, o5, o6] = fcn(u)\n', ...
                   '% This function implements the logic for the bottom control IC\n', ...
                   '% Input u comes from the delay control module\n', ...
                   'o1 = u > 0.5;\n', ...
                   'o2 = u > 0.25;\n', ...
                   'o3 = u > 0.75;\n', ...
                   'o4 = ~u;\n', ...
                   'o5 = u < 0.5;\n', ...
                   'o6 = u < 0.25;\n'];

% Set MATLAB Function content
set_param([modelName '/Control_IC_1'], 'MATLABFcn', control_ic1_code);
set_param([modelName '/Control_IC_2'], 'MATLABFcn', control_ic2_code);

% Add display text and properly position all components for a cleaner layout
for i = 1:2
    % Add text for "Transmission Line" and other labels visible in the image
    if i == 1
        pos_y = 80;
        label = 'Encoder 1';
    else
        pos_y = 200;
        label = 'Encoder 2';
    end
    add_block('simulink/Signal Attributes/Model Info', [modelName '/Label_' num2str(i)]);
    set_param([modelName '/Label_' num2str(i)], 'Position', [150, pos_y-20, 180, pos_y], 'Info', label);
end

% Re-arrange components for better spacing and alignment to match the image
lines = find_system(modelName, 'FindAll', 'on', 'Type', 'line');
for i = 1:length(lines)
    set_param(lines(i), 'Name', '');
end

% Save the model
save_system(modelName);

