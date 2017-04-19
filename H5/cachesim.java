import java.io.*;
import java.util.*;

public class cachesim {
    
    public static int cacheSize, assoc, blockSize, numBlocks, numSets, tagBits, numSetBits, bOFSbits;   //initialize global variables
    public static String cacheType;
    public static int addressBits = 24;                                     // address = 24 bits
    static String[] mainMemory = new String[(int) Math.pow(2,24)];          // main memory initialize (string array)
    static cache cache;
    
    public static void main(String[] args) throws IOException{              // parse data from text file into variables
        Arrays.fill(mainMemory, "00");                                      // initialize values in main memory
        cachesim cachesim = new cachesim();
        
        // PARSE THROUGH COMMAND LINE ARGUMENTS
        File Trfile = new File(args[0]);                                    // initialize file for scanner
        
        cacheSize = 1024*Integer.parseInt(args[1]);                         // from KB to B: 1024B = 1 KB, so 1024KB = 1024*1024B
        assoc = Integer.parseInt(args[2]);                                  // get associativity and convert to integer
        cacheType = args[3];                                                // whether cache is wb or wt
        blockSize = Integer.parseInt(args[4]);                              // parseInt returns primitive int, valueOf returns new Integer() object
        
        numBlocks = cacheSize/blockSize;                                    // number of blocks
        numSets = numBlocks/assoc;
        cache = cachesim.new cache();                                       // number of sets
        
        numSetBits = logCompute(numSets, 2);                                // compute number of bits for each set index
        bOFSbits = logCompute(blockSize, 2);                                // compute number of bits for each block offset
        
        tagBits = addressBits - numSetBits - bOFSbits;                      // tag bits are bits left over
        
         // PARSE INFORMATION FROM FILE LINE
        Scanner scanner = new Scanner(Trfile);                              // initialize Scanner to read from file
        while(scanner.hasNextLine()){
            String line = scanner.nextLine();
            int firstBreak = line.indexOf(" ");
            String loadORstore = line.substring(0, firstBreak);             // string until first space identifies load or store
            line = line.substring(firstBreak+1,line.length());
            
            int secondBreak = line.indexOf(" ");
            String addr = line.substring(0, secondBreak);                   // string until second space is the address
            
            line = line.substring(secondBreak+1,line.length());
            
            int sizeOfAccess = 0;                                           // size of access in bytes
            String sw = null;
            if (loadORstore.equals("store")){
                int thirdBreak = line.indexOf(" ");
                String accByt = line.substring(0, thirdBreak);
                sizeOfAccess = Integer.parseInt(accByt);                    // string until 3rd space is access bytes
                sw = line.substring(thirdBreak+1,line.length());            // last word is value to be written if access is store
            }
            else sizeOfAccess = Integer.parseInt(line);                     // last word is access bytes if access is load
            
            String address = Integer.toBinaryString(Integer.parseInt(addr.substring(2,addr.length()), 16)); // make binary address; base 16 to base 2
            while(address.length()<addressBits) address = "0"+address;                                      // make sure address is 24 bits
            
            int opTag = Integer.parseInt(address.substring(0, tagBits),2);
            int opIndex = Integer.parseInt(address.substring(tagBits, numSetBits+tagBits),2);
            int opOffset = Integer.parseInt(address.substring(numSetBits+tagBits),2);
            int opAddr = Integer.parseInt(address,2);                                                       // make address from binary to decimal
            
            if (loadORstore.equals("load")){                                                                                                        // perform load and print result
                System.out.println("load "+addr+" "+cachesim.load(address, sizeOfAccess, opTag, opIndex, opOffset, opAddr));
            }
            else System.out.println("store "+addr+" "+cachesim.store(address, sizeOfAccess, cacheType, sw, opTag, opIndex, opOffset, opAddr));      // perform store and print result
        }
        //      scanner.close();
    }
    
    public class cache_set{                                                 // initialize set as LinkedList of frames
        LinkedList<frame> frames;
        public cache_set(){
            frames = new LinkedList<frame>();
        }
    }
    
    public class cache{                                                     // initialize cache, which is set of sets
        cache_set[] set;
        public cache(){
            set = new cache_set[numSets];
            for(int i=0; i<numSets; i++){
                set[i] = new cache_set();
            }
        }
    }
    
    public class frame{                                                     // initialize frame
        String data;
        int tag;
        boolean dirty;
        
        public frame(int t, String dat, boolean d){
            tag = t;
            data = dat;
            dirty = d;
        }
    }
    
    public String load(String address, int accessSize, int tag, int index, int offset, int addr){
        LinkedList<frame> blocks = cache.set[index].frames;                                              //loop through linked list to see if tags match
        for(int j=0; j<blocks.size(); j++){
            if(tag == blocks.get(j).tag) return "hit "+blocks.get(j).data.substring(2*offset, 2*(accessSize+offset));
        }

        // getting block from main memory
        int startLoop = addr - addr%blockSize;
        String fromMemory = "";
        for(int i = startLoop; i<startLoop+blockSize; i++) fromMemory += mainMemory[i];
        
        frame newFrame = new frame(tag, fromMemory, false);                                             // make new frame
        blocks.offerFirst(newFrame);                                                                    // add to front of LRU
        if(blocks.size()>assoc) blocks.removeLast();
        return "miss "+newFrame.data.substring(2*offset, 2*(accessSize+offset));                        //get access size bytes
    }
    
    public String store(String address, int accessSize, String cacheType, String sw, int tag, int index, int offset, int addr){
        //loop through linked list to see if tags match
        LinkedList<frame> blocks = cache.set[index].frames;
        for(int i=0; i<blocks.size();i++){
            if(blocks.get(i).tag == tag){
                // if(cacheType.equals("wt")) mainMemory[addr] = blocks.get(i).data;                       // if wt write block to memory
                
                // blocks.get(i).dirty = true;                                                             // set dirty bit
                blocks.offerFirst(blocks.get(i));                                                          // store to cache
                return "hit";
            }
          }
        if(blocks.size()>assoc){                                                                                    // check if list full
            // if(cacheType.equals("wb") && blocks.getLast().dirty==true){
            //     //write to memory
            //     int addPosition = addr;
            //     int i=0;
            //     while(i<sw.length()){
            //         mainMemory[addPosition] = sw.substring(i,i+2);
            //         addPosition+=1;
            //         i+=2;
            //     }
            // }
            blocks.removeLast();                                                                            // evict
        }
//        if(cacheType.equals("wt")){
            //write to memory
            int addPosition = addr;
            int i=0;
            while(i<sw.length()){
                mainMemory[addPosition] = sw.substring(i,i+2);
                addPosition+=1;
                i+=2;
            }
//        }
        if(cacheType.equals("wb")){
            // write to cache
            int startLoop = addr - addr%blockSize;
            String fromMemory = "";
            for(int j = startLoop; j<startLoop+blockSize; j++) fromMemory += mainMemory[j];
            
            // add block to cache
            frame newFrame = new frame(tag, fromMemory, true);                                                          // make new frame
            blocks.offerFirst(newFrame);                
            if(blocks.size()>assoc) blocks.removeLast();
            
//          int len = sw.length();
//          while(sw.length()<2*offset+len) sw="0"+sw;
//          while(sw.length()<2*blockSize) sw=sw+"0";
//
//          // add block to cache
//          frame newFrame = new frame(tag, sw, true);                                                          // make new frame
//          blocks.offerFirst(newFrame);                                                                        // add block to cache in both cases
        }
        return "miss";
    }
    
    public static int logCompute(int x, int base){      // log computation
        return (int) (Math.log(x) / Math.log(base));
    }
}