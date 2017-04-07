function integer bits_to_fit;
  input [31:0] value;
  for (bits_to_fit=0; value>0; bits_to_fit=bits_to_fit+1)
    value = value >> 1;
endfunction
