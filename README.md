#usage (build + generate)

conf=[conf_filename] output=[output_folder] ./run.sh

#build only

haxe -main Main -D nodejs -lib hxnodejs -js db2hx.js

# generate only 

iconf=[conf_filename] output=[output_folder] node db2hx.js
