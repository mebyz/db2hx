npm install
npm update

echo "#clone clemos/haxe-js-kit"
rm -rf haxe-js-kit/
git clone https://github.com/clemos/haxe-js-kit.git haxe-js-kit

conf=$conf output=$output ./run.sh
