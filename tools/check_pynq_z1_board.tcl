puts "Vivado version: [version -short]"
puts "Matching board parts:"
foreach bp [get_board_parts -quiet *pynq*] {
  puts "  $bp"
}
puts "Matching xc7z020clg400 parts:"
foreach p [get_parts -quiet xc7z020clg400*] {
  puts "  $p"
}
