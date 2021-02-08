package Assembler;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Scanner;

import java.io.File;
import java.io.FileWriter;

public class Assembler {

	private static ArrayList<String> instructions = new ArrayList<String>(Arrays.asList(new String[]{
        // ALU Operations
        "ADD", "SUB", "NEG", "INC",
        "DEC", "AND", "OR", "XOR" , 
        "NOT", "ASR", "ASL", "LSR", 
        "LSL", "CSR", "CSL", 
        
        // MOV Operation
        "MOV",
        
        // RAM Operations
        "LD", "STR",

        // Other Instructions
        "NOP", "CMP", "RES",

        // JUMP Instructions (Comparator)
        "JG", "JGE", "JE", "JNE",
        "JLE", "JL", 
        
        // Jump Instructions (CPSR)
        "JC", "JZ", "JN", "JO",
        "JP", "JNC", "JNZ", "JNN",
        "JNO", "JNP"
    }));

    private static ArrayList<String> codes = new ArrayList<String>(Arrays.asList(new String[]{
        // ALU Operations
        "000000", "000100", "001000", "001100",
        "010000", "011000", "011100", "100000" , 
        "100100", "101000", "101100", "110000", 
        "110100", "111000", "111100",
        
        // MOV Operation
        "010100",
        
        // RAM Operations
        "000001", "000010",

        // Other Instructions
        "001111", "000111", "000011",

        // JUMP Instructions (Comparator)
        "001011", "001011", "001011", "001011",
        "001011", "001011", 
        
        // Jump Instructions (CPSR)
        "001011", "001011", "001011", "001011",
        "001011", "001011", "001011", "001011",
        "001011", "001011"
    }));
	

	public static void main(String[] args) {
        StringBuilder executable = new StringBuilder();
		try {
			File inputFile = new File(args[0]);
			if (inputFile.exists()) {
                Scanner sc = new Scanner(inputFile);
                int lineNumber = 1;
				while(sc.hasNextLine()) {
                    String line = sc.nextLine();
                    line = line.toUpperCase();
                    if(line.trim().length() != 0){
                        if(line.trim().charAt(0) != ';') {
                            String parsed = parseLine(line, lineNumber);

                            executable.append(toHex(parsed).toUpperCase() + "\n");
                            lineNumber++;
                        }
                    }
                }
                sc.close();
			} else {
                System.out.println("Input file does not exist...");
                System.exit(-1);
            }
            
            File outputFile = new File(args[1]);
            if(!outputFile.exists()) {
                System.out.println("Output file does not exist...");
                System.out.println("Creating output file: " + args[1]);
                outputFile.createNewFile();
            } 
            FileWriter fw = new FileWriter(outputFile, false);
            /* Not needed
            String fileFormat =
            "DEPTH = 4096;                   -- The size of memory in words\n" +
            "WIDTH = 32;                    -- The size of data in bits\n" +
            "ADDRESS_RADIX = HEX;          -- The radix for address values\n" +
            "DATA_RADIX = HEX;             -- The radix for data values\n" +
            "CONTENT                       -- start of (address : data pairs)\n" +
            "BEGIN\n" +
            "-- memory address : data\n" +
            "%s" +
            "END;\n";
            


            String lines[] = executable.toString().split("\n");
            StringBuilder content = new StringBuilder();

            for(int i = 0; i < lines.length; i++) {
                content.append("" + toHex(toBinary(i, 12)) + " : " + lines[i] + ";\n");
            }

            fw.write(String.format(fileFormat, content));
            */

            fw.write(executable.toString());

            fw.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
    }

    private static String toHex(String bin) {
        String hex = "";

        for(int i = bin.length() - 1; i > 0; i-=4) {
            int hexdigit = 0;
            for(int j = i; j > i-4 && j >= 0; j--) {
                hexdigit += (bin.charAt(j) == '1' ? 1: 0) * Math.pow(2, i-j);
            }
            
            hex = Integer.toString(hexdigit, 16) + hex;
        }

        return hex;
    }
    
    private static String toBinary(int number, int length) {
        String bin = Integer.toBinaryString((0x1 << (length)) | number).substring(1);
        return bin;
    }
	
	private static String parseLine(String line, int lineNumber) {
        String binaryLine = "";

        String words[] = line.replaceAll(",", "").split(" ");

        String instruction = words[0];

        boolean immediate = false;

        for(int i = 1; i < words.length; i++) {
            if(words[i].charAt(0) != 'R') {
                if(words.length >= 4) {
                    if(!words[i].substring(0, 3).equals("ACC")) {
                        immediate = true;
                        break;
                    } 
                } else {
                    immediate = true;
                    break;
                }
            }
        }

        binaryLine += immediate ? "1": "0"; // Decide for the Immediate bit

        int indexOfInstruction = instructions.indexOf(instruction);

        if(indexOfInstruction == -1) {
            System.err.println("Instruction: \"" + instruction + "\" at line " + lineNumber + " is not supported.");
            System.exit(-1);
        }

        binaryLine += indexOfInstruction < 17 ? "1" : "0"; // Decide for the RegWr bit

        binaryLine += indexOfInstruction > 20 ? toBinary(indexOfInstruction - 21, 4) : "0000";

        String operands[] = new String[words.length - 1];

        for(int i = 1; i < words.length; i++) {
            operands[i-1] = words[i];
        }

        binaryLine += parseOperands(indexOfInstruction, operands, immediate); // Put the bits related to instruction operands.

        binaryLine += codes.get(indexOfInstruction);

        return binaryLine;
    }

	private static String parseOperands(int insIndex, String[] operands, boolean immediate) {
        String binary = "";
        
        String instruction = instructions.get(insIndex);

        for(int i = 0; i < operands.length; i++) {
            if(operands[i].startsWith("R")) {
                operands[i] = operands[i].replaceAll("R", "");    
            } else if (operands[i].startsWith("ACC")) {
                operands[i] = Integer.toString(Integer.parseInt(operands[i].replaceAll("ACC", "")) + 12);
            }
            
        }

        if(immediate) {
            if(instruction.equals("LD") || instruction.equals("STR")) {
                binary += "0000";

                int address = Integer.parseInt(operands[1]);

                binary += toBinary(address, 12);

                int registerIndex = Integer.parseInt(operands[0]);

                binary += toBinary(registerIndex, 4);

            } else if(instruction.equals("MOV")){
                int value = Integer.parseInt(operands[1]);

                binary += toBinary(value, 16);

                int registerIndex = Integer.parseInt(operands[0]);

                binary += toBinary(registerIndex, 4);
            } else {
                int value = Integer.parseInt(operands[0]);

                binary += toBinary(value, 16);

                binary += "0000";
            }
        } else {
            binary += "00000000";
            if(instruction.equals("INC") || instruction.equals("DEC") || instruction.equals("NOT") || instruction.equals("MOV")) {
                binary += "0000";

                int xRegisterIndex = Integer.parseInt(operands[1]);

                binary += toBinary(xRegisterIndex, 4);

                int zRegisterIndex = Integer.parseInt(operands[0]);

                binary += toBinary(zRegisterIndex, 4);
                
            } else if(instruction.equals("LD")) {
                int yRegisterIndex = Integer.parseInt(operands[1]);

                binary += toBinary(yRegisterIndex, 4);
                
                binary += "0000";

                int zRegisterIndex = Integer.parseInt(operands[0]);

                binary += toBinary(zRegisterIndex, 4);
            } else if(instruction.equals("STR") || instruction.equals("CMP")) {
                int yRegisterIndex = Integer.parseInt(operands[1]);

                binary += toBinary(yRegisterIndex, 4);

                int xRegisterIndex = Integer.parseInt(operands[0]);

                binary += toBinary(xRegisterIndex, 4);

                binary += "0000";
            } else if(instruction.equals("NOP") || instruction.equals("RES")) {
                binary += "000000000000";
            } else if(insIndex < 15) {
                int yRegisterIndex = Integer.parseInt(operands[2]);

                binary += toBinary(yRegisterIndex, 4);
                
                int xRegisterIndex = Integer.parseInt(operands[1]);

                binary += toBinary(xRegisterIndex, 4);

                int zRegisterIndex = Integer.parseInt(operands[0]);

                binary += toBinary(zRegisterIndex, 4);
            } else {
                int yRegisterIndex = Integer.parseInt(operands[0]);

                binary += toBinary(yRegisterIndex, 4);

                binary += "00000000";
            }
        }

        return binary;
	}
	
}