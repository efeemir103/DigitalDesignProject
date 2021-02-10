module MainDesign(
	// General I/O
	input clk,
	input res,
	
	// Digital Tube:
	input [3:0] btns,
	output reg [3:0] dig,
	output [7:0] seg,
	
	// Infrared:
	input ir,
	
	// VGA:
	output [2:0] rgbOut,
	output hsync,
	output vsync
);

	wire enable;
	assign enable = 1'b1;

	// Peripheral Registers:
	reg [15:0] digitalTube;	// Digital Tube
	reg [15:0] regIRHigh; // Infrared
	reg [15:0] regIRLow; // Infrared
	
	
	// ### CPU ROM ###:
	wire ROMaddr;
	reg [31:0] ROM [4095:0];
	reg [31:0] ROMdata;
	
	initial begin
		$readmemh("ROM.hex", ROM);
	end
	
	always @(posedge clk)
	begin
		ROMdata <= ROM[ROMaddr];
	end

	// ### Dual Port Block RAM ###:
	wire [15:0] data_a;
	wire [15:0] data_b;
	
	wire [11:0] addr_a;
	wire [11:0] addr_b;
	wire we_a, we_b;
	wire clr;
	reg [15:0] q_a, q_b;
	assign data_a = 16'h0000;
	assign we_a = 1'b0;

	// Declare the RAM variable
	reg [15:0] RAM [4095:0];

	// Port A for VGA Controller Only Read
	always @(posedge clk)
	begin
		if (we_a) 
		begin
			RAM[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= RAM[addr_a];
		end 
	end 

	// Port B for CPU/Digital Tube/Infrared Read & Write
	always @(posedge clk)
	begin
		if (we_b)
		begin
			RAM[addr_b] <= data_b;
			q_b <= data_b;
		end
		else 
		begin
			q_b <= RAM[addr_b];
		end 
	end
	
	/*
	initial begin
		$readmemb("initram.bin", RAM);
	end
	*/
	
	// ### BUS ###:
	// Data/Address BUS to handle Infrared/Button/Digital Tube outputs as RAM entries:
	reg [12:0] clearCounter; // Counter to index while RAM Cleaning and stop CPU clock
	reg clearFlag; // Register to flag RAM Cleaning and stop CPU clock
	reg passToRAM; // Use RAM for data read/write
	reg weRAM; // Write enable for RAM
	wire clrRAM; // Clear for RAM
	wire selBUS; // Chip select for BUS
	wire loadBUS; // ~we for RAM
	wire [11:0] addrBUS;
	wire [15:0] dataBUSIn;
	reg [15:0] dataBUSOut;
	integer i;
	always @(posedge clk)
	begin
		if(clearFlag)
		begin
			passToRAM <= 1'b1;
			weRAM <= 1'b1;
			
			clearCounter <= clearCounter + 13'd1;
			
			if(clearCounter == 13'd4096)
			begin
				clearFlag <= 1'b0;
				weRAM <= 1'b0;
			end
		end
		else if(clrRAM)
		begin
			/*
			passToRAM <= 1'b0;
			clearCounter <= 13'd0;
			clearFlag <= 1'b1;
			*/
		end
		else if(~selBUS)
		begin
			passToRAM <= 1'b0;
		
			weRAM <= 1'b0;
			dataBUSOut <= 16'h0000;
		end
		else if(addrBUS == 12'd110)
		begin
			passToRAM <= 1'b0;
			
			// Digital Tube binded to RAM address 110
			if(loadBUS)
			begin
				dataBUSOut <= digitalTube;
			end
			else
			begin
				digitalTube <= dataBUSIn;
			end
		end
		else if(addrBUS == 12'd111)
		begin
			passToRAM <= 1'b0;
			
			// Buttons binded to RAM address 111
			if(loadBUS)
			begin
				dataBUSOut <= {12'h000, ~btns};
			end
		end
		else if(addrBUS == 12'd112)
		begin
			passToRAM <= 1'b0;
		
			if(loadBUS)
			begin
				dataBUSOut <= regIRHigh;
			end
		end
		else if(addrBUS == 12'd113)
		begin
			passToRAM <= 1'b0;
		
			if(loadBUS)
			begin
				dataBUSOut <= regIRLow;
			end
		end
		else
		begin
			passToRAM <= 1'b1;
			
			if(loadBUS)
			begin
				weRAM <= 1'b1;
			end
			else
			begin
				dataBUSOut <= q_b;
				weRAM <= 1'b0;
			end
		end
	end
	
	assign we_b = passToRAM & weRAM;
	assign addr_b = clearFlag ? clearCounter : addrBUS;
	assign data_b = clearFlag ? 16'h0000 : dataBUSIn;
	

	
	// ### CPU ###:
	wire dummy;
	
	CPUv2(
		~clearFlag & clk,
		clearFlag | ~res,
		enable,
		
		// Instruction fetch pins (ROM)
		ROMaddr, // ROM address
		ROMdata, // ROM data
		dummy, // Ignore ROM chip select
		
		// Data load/str pins (RAM)
		addrBUS,
		dataBUSOut, // RAM Port B Out
		dataBUSIn, // RAM Port B In
		selBUS, // Chip select for BUS
		loadBUS, // Load from BUS
		clrRAM // RAM clear
	);
	
	
	// ### Digital Tube ###:
	reg clock1KHz;
	reg [15:0] pulseCount;
	
	reg [2:0] counter;
	reg [15:0] hexSel;
	
	reg [6:0] hexEncoding;
	
	initial begin
		clock1KHz <= 1'b0;
		pulseCount <= 16'd0;
		
		dig <= 4'b0111;
		counter <= 3'b000;
		hexSel <= 16'h0000;
	end
	
	always @(posedge clk)
	begin
		if(~res)
		begin
			clock1KHz <= 1'b0;
			pulseCount <= 16'd0;
		end
		
		// 50000 clock cycles are needed to count for 1KHz clock (50000 division):
		if(pulseCount == 16'd50000)
		begin
			pulseCount <= 16'd0;
			clock1KHz <= 1'b0;
		end
		else 
		begin
			if(pulseCount == 16'd25000)
			begin
				clock1KHz <= 1'b1;
			end
			
			pulseCount <= pulseCount + 16'd1;
		end
	end
	
	always @(posedge clock1KHz)
	begin
		if(~res)
		begin
			dig <= 4'b0111;
			counter <= 3'b000;
			hexSel <= 16'h0000;
		end
			
		if(counter == 3'b100)
		begin
			dig <= 4'b0111;
			hexSel <= digitalTube;
			counter <= 3'b000;
		end
		else
		begin
			dig <= {dig[2:0], dig[3]};
			
			// Set digital tube to show recieved code:
			case (hexSel[3:0])
				4'b0000 : hexEncoding <= 7'h3f;
				4'b0001 : hexEncoding <= 7'h06;
				4'b0010 : hexEncoding <= 7'h5b;
				4'b0011 : hexEncoding <= 7'h4f;
				4'b0100 : hexEncoding <= 7'h66;          
				4'b0101 : hexEncoding <= 7'h6d;
				4'b0110 : hexEncoding <= 7'h7d;
				4'b0111 : hexEncoding <= 7'h07;
				4'b1000 : hexEncoding <= 7'h7f;
				4'b1001 : hexEncoding <= 7'h6f;
				4'b1010 : hexEncoding <= 7'h77;
				4'b1011 : hexEncoding <= 7'h7c;
				4'b1100 : hexEncoding <= 7'h39;
				4'b1101 : hexEncoding <= 7'h5e;
				4'b1110 : hexEncoding <= 7'h79;
				4'b1111 : hexEncoding <= 7'h71;
			endcase
			
			hexSel <= {4'b0000, hexSel[15:4]};
			counter <= counter + 3'b001;
		end
	end
	
 
	assign seg[7] = ir;
	assign seg[6] = ~hexEncoding[6];
	assign seg[5] = ~hexEncoding[5];
	assign seg[4] = ~hexEncoding[4];
	assign seg[3] = ~hexEncoding[3];
	assign seg[2] = ~hexEncoding[2];
	assign seg[1] = ~hexEncoding[1];
	assign seg[0] = ~hexEncoding[0];

	
	
	// ### IR Controller ###:
	wire [31:0] code;
	wire dataValid;
	
	IRController(
		clk,
		~res,
		ir,
		code,
		dataValid
	);
	
	initial begin
		regIRHigh <= 16'h0000;
		regIRLow <= 16'h0000;
	end
	
	always @(posedge dataValid or negedge res)
	begin
		 regIRHigh <= code[31:16];
		 regIRLow <= code[15:0];
	end

	
	// ASCII Character ROM
	wire [13:0] fontROMAddr;
	reg fontROM [16383:0];
	reg fontROMOut;

	initial begin
		$readmemb("glyph.bin", fontROM);
	end

	always @(posedge clk)
	begin
		fontROMOut <= fontROM[fontROMAddr];
	end
	
	// ### VGA Controller ###:

	VGAController(
		clk,
		hsync,
		vsync,
		rgbOut,
		res,
		fontROMAddr,
		fontROMOut,
		addr_a,
		q_a
	);
	
endmodule
