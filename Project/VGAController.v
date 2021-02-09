module VGAController(
	// 50 Mhz clock
	input clk,

	output hsync,
	output vsync,
	output [2:0] rgbOut,

	// Clock Reset
	input rst,

	output [13:0] ROMAddr,
	input ROMOut,
	output [11:0] RAMAddr,
	input [15:0] RAMOut
);

	wire inDisplayArea;
	wire [9:0] PosX;
	wire [9:0] PosY;

	// 25Mhz Clock generator
	reg clk25MHz;
	always @(posedge clk)
	begin
	if (~rst)
	clk25MHz <= 1'b0;
	else
	clk25MHz <= ~clk25MHz;	
	end

	wire hsyncOrig, vsyncOrig, inDisplayAreaOrig;

	HVSync(clk25MHz, hsyncOrig, vsyncOrig, inDisplayAreaOrig, PosX, PosY);

	// Drawing Logic goes here
	wire [7:0] asciiData;
	wire [2:0] colorF;
	wire [2:0] colorB;

	assign asciiData = RAMOut[15:8];
	assign colorF = RAMOut[7:5];
	assign colorB = RAMOut[4:2]; // 2 bit unused for now...

	// (PosX / 8) + (PosY / 16) * 80 Text Indexing
	assign RAMAddr = {5'b00000, PosX[9:3]} + ({6'b000000, PosY[9:4]} * 80);

	reg [2:0] CharX;
	reg [3:0] CharY;
	always @ (posedge clk) // Adds 1 clock delay to sync, compensating the RAM delay.
	begin
	CharX <= PosX[2:0];
	CharY <= PosY[3:0];
	end

	assign ROMAddr = {asciiData[6:0], 7'b0000000 } + CharX[2:0] + {CharY[3:0], 3'b000}; // Text Pixel Indexing

	assign rgbOut[0] = ROMOut ? (colorF[0] & inDisplayArea) : (colorB[0] & inDisplayArea);
	assign rgbOut[1] = ROMOut ? (colorF[1] & inDisplayArea) : (colorB[1] & inDisplayArea);
	assign rgbOut[2] = ROMOut ? (colorF[2] & inDisplayArea) : (colorB[2] & inDisplayArea);


	reg hsyncDelayed1, hsyncDelayed2, hsyncDelayed3;
	reg vsyncDelayed1, vsyncDelayed2, vsyncDelayed3;
	reg inDisplayAreaDelayed1, inDisplayAreaDelayed2;


	always@(posedge clk) begin
	hsyncDelayed1 <= hsyncOrig;
	hsyncDelayed2 <= hsyncDelayed1;
	hsyncDelayed3 <= hsyncDelayed2;

	vsyncDelayed1 <= vsyncOrig;
	vsyncDelayed2 <= vsyncDelayed1;
	vsyncDelayed3 <= vsyncDelayed2;

	inDisplayAreaDelayed1 <= inDisplayAreaOrig;
	inDisplayAreaDelayed2 <= inDisplayAreaDelayed1;
	end

	assign hsync = hsyncDelayed3;
	assign vsync = vsyncDelayed3;
	assign inDisplayArea = inDisplayAreaDelayed2;

endmodule