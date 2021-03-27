test:
	vusted --shuffle
.PHONY: test

COMPARE_HASH := HEAD^
RESULT_DIR := ./spec/lua/reacher/virtes/screenshot
diff_screenshot:
	nvim --clean -n +"lua dofile('./spec/lua/reacher/virtes/scenario.lua')('${COMPARE_HASH}', '${RESULT_DIR}')" +"quitall!"
	cat ${RESULT_DIR}/replay.vim
	test ! -s ${RESULT_DIR}/replay.vim
.PHONY: diff_screenshot

doc:
	nvim --headless -i NONE -n +"lua dofile('./spec/lua/reacher/doc.lua')" +"quitall!"
	cat ./doc/reacher.nvim.txt
.PHONY: doc
