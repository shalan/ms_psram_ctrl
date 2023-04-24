module ms_psram_ctrl_ahb_tb;
    wire[3:0] dio;
    reg            HCLK = 0;
    reg            HRESETn = 0;
    reg            HSEL = 1;
    reg [31:0]     HADDR;
    reg [31:0]     HWDATA;
    reg [1:0]      HTRANS = 0;
    reg            HWRITE = 0;
    reg [2:0]       HSIZE;
    wire           HREADY;
    wire           HREADYOUT;
    wire [31:0]     HRDATA;
    
    wire            sck;
    wire            ce_n;
    wire [3:0]      din;
    wire [3:0]      dout;
    wire [3:0]      douten;    

    `include "AHB_tasks.vh"

    AHB_PSRAM_CTRL psram_ctrl(
        // AHB-Lite Slave Interface
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HSEL(HSEL),
        .HADDR(HADDR),
        .HWDATA(HWDATA),
        .HTRANS(HTRANS),
        .HSIZE(HSIZE),
        .HWRITE(HWRITE),
        .HREADY(HREADY),
        .HREADYOUT(HREADYOUT),
        .HRDATA(HRDATA),

        .sck(sck),
        .ce_n(ce_n),
        .din(din),
        .dout(dout),
        .douten(douten)     
    );

    assign dio[0] = douten[0] ? dout[0] : 1'bz;
    assign dio[1] = douten[0] ? dout[1] : 1'bz;
    assign dio[2] = douten[0] ? dout[2] : 1'bz;
    assign dio[3] = douten[0] ? dout[3] : 1'bz;

    assign din = dio;
    
    psram sram (
        .sck(sck),
        .dio(dio),
        .ce_n(ce_n)
    );

    initial begin
        $dumpfile("psram_tb.vcd");
        $dumpvars;
        #999;
        @(posedge HCLK)
            HRESETn <= 1;
        #1000_000 $finish;
    end

    always #10 HCLK = ~HCLK;
    
    reg [31:0] data;
    initial begin
        @(posedge HRESETn);
        #999;
        @(posedge HCLK);
        AHB_WRITE_WORD(0, 32'hABCD_1234);
        AHB_READ_WORD(0, data);
        #1;
        $display("read: %x", data);
        AHB_READ_BYTE(2,data);
        #1;
        $display("read: %x", data);
        AHB_WRITE_WORD(100, 32'h88776655);
        AHB_READ_WORD(100, data);
        #1;
        $display("read: %x", data);
        AHB_READ_HALF(100, data);
        #1;
        $display("read: %x", data);
        AHB_READ_HALF(101, data);
        #1;
        $display("read: %x", data);
    end

    assign HREADY = HREADYOUT;


endmodule