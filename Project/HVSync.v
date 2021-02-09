module HVSync(
    // 25 Mhz clock
    input clk25MHz,

    output reg hsync,
    output reg vsync,
    output reg inDisplayArea,
    
    // Module Interfaces
    output reg [9:0] counterX,
    output reg [9:0] counterY
);

  wire counterXmaxed = (counterX == 800); // 16 + 48 + 96 + 640
  wire counterYmaxed = (counterY == 525); // 10 + 2 + 33 + 480

  always @(posedge clk25MHz)
  begin
    if (counterXmaxed)
    begin
      counterX <= 0;
    end
    else
    begin
      counterX <= counterX + 1;
    end
  end

  always @(posedge clk25MHz)
  begin
    if (counterXmaxed)
    begin
      if(counterYmaxed)
      begin
        counterY <= 0;
      end
      else
      begin
        counterY <= counterY + 1;
      end
    end
  end

  always @(posedge clk25MHz)
  begin
    hsync <= ~(counterX > (640 + 16) && (counterX < (640 + 16 + 96)));  // active for 96 clocks
    vsync <= ~(counterY > (480 + 10) && (counterY < (480 + 10 + 2)));   // active for 2 clocks
  end

  always @(posedge clk25MHz)
  begin
    inDisplayArea <= (counterX < 640) && (counterY < 480);
  end
	 
endmodule
