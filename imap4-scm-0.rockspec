package = "imap4"
version = "scm-0"
description = {
	summary = "Simple IMAP4 protocol wrapper.",
	detailed = [[
		imap4.lua is a thin abstraction layer above RFC 3501 (IMAP4rev1), upon
		which more complex systems can be built.
	]],
	license = "modified MIT",
	homepage = "https://github.com/vrld/imap4.lua",
}

dependencies = {
	"lua >= 5.1",
	"luasocket>=2.0.2",
	"luasec>=0.4",
}

source = {
	url = "git://github.com/vrld/imap4.lua.git",
	branch = "master",
}

build = {
	type = "builtin",
	modules = {
		imap4 = "imap4.lua",
	}
}
