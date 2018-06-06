// MBT 5-22-16
//
// Given a bit vector, return a one-hot bit vector
// that has the latest/earliest bit selected.
//
// Can combine with bsg_encode_one_hot
// to get typical priority encoder.
//

module bsg_priority_encode_one_hot_out4 #(parameter width_p      = 4
                                         , parameter lo_to_hi_p = 1
                                         )

   (input    [width_p-1:0] i
    , output [width_p-1:0] o
    );

   logic [width_p-1:0] scan_lo;

   bsg_scan4  scan (.i (i)
                      ,.o(scan_lo)
                      );

   // edge detect
   if (lo_to_hi_p)
     assign o = scan_lo & { (~scan_lo[width_p-2:0]), 1'b1 };
   else
     assign o = scan_lo & { 1'b1, (~scan_lo[width_p-1:1]) };

endmodule
