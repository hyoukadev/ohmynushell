use ./files.nu symlink
use std/assert

let root = (mktemp --directory)
let source_dir = ($root | path join source)
let target_dir = ($root | path join target)
mkdir $source_dir
"source stays intact" | save ($source_dir | path join marker.txt)

# Creating and reapplying a directory link must never resolve the destination
# and move/delete the source directory.
symlink $target_dir $source_dir
symlink $target_dir $source_dir
assert ($source_dir | path exists)
assert (($source_dir | path join marker.txt) | path exists)
assert equal (open ($target_dir | path join marker.txt)) "source stays intact"

let source_file = ($root | path join source.txt)
let target_file = ($root | path join target.txt)
"same content" | save $source_file
symlink $target_file $source_file
symlink $target_file $source_file
assert ($source_file | path exists)
assert equal (open $target_file) "same content"

# Remove links before the shared temporary root.
rm $target_file
rm $target_dir
rm -r $root
