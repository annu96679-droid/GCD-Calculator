# GCD-Calculator
Greatest Common Divisor (GCD) Calculator using the Euclidean Algorithm, implemented for both software and FPGA-based digital circuits.


graph TB
    subgraph UART Transmitter Block Diagram
        %% Clock and Control Section
        CLK[System Clock] --> BRG[Baud Rate Generator<br/>Clock Divider]
        RESET[Reset] --> CTRL[Control Logic]
        CONFIG[Configuration Registers<br/>Data Bits, Parity, Stop Bits] --> BRG
        CONFIG --> CTRL
        
        %% Data Path Section
        DATA_IN[Parallel Data In<br/>7:0] --> TDR[Transmit Data Register<br/>Double Buffered]
        TX_START[Transmit Start] --> FSM[TX Finite State Machine]
        
        %% Baud Generation
        BRG --> BAUD_TICK[Baud Clock Tick]
        BAUD_TICK --> FSM
        
        %% Shift Register Path
        TDR --> |Parallel Load| TSR[Transmit Shift Register<br/>Serial Output]
        FSM --> |tsr_load| TSR
        FSM --> |tsr_shift| TSR
        TSR --> |serial_data| MUX[Output Multiplexer]
        
        %% Parity Generation
        TDR --> PARITY_GEN[Parity Generator<br/>XOR Tree]
        PARITY_GEN --> |parity_bit| MUX
        
        %% Output Control
        FSM --> |mux_sel[2:0]| MUX
        MUX --> TX_OUT[TX Serial Output]
        
        %% Status Signals
        FSM --> TX_BUSY[TX Busy Flag]
        FSM --> TX_DONE[TX Complete]
        FSM --> TDR_EMPTY[TDR Empty Flag]
        
        %% Style Definitions
        style FSM fill:#bbdefb
        style TSR fill:#d1c4e9
        style BRG fill:#c8e6c9
        style TDR fill:#ffcdd2
        style PARITY_GEN fill:#ffecb3
        style MUX fill:#d7ccc8
        style CLK fill:#e1f5fe
        style RESET fill:#fce4ec
        style CONFIG fill:#f3e5f5
        style DATA_IN fill:#e8f5e8
        style TX_START fill:#fff3e0
        style BAUD_TICK fill:#ffebee
        style TX_OUT fill:#e0f2f1
        style TX_BUSY fill:#f9fbe7
        style TX_DONE fill:#fff8e1
        style TDR_EMPTY fill:#efebe9
    end
