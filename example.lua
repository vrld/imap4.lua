require 'luarocks.require'

local imap4 = require 'imap4'

-- If in doubt, see RFC 3501:
-- https://tools.ietf.org/html/rfc3501#section-6

-- Create new imap4 connection.
-- Port is optional and defaults to 143.
local connection = imap4('localhost', 143)

-- If you are connecting to gmail, yahoo or any other server that needs a SSL
-- connection before accepting commands, uncomment this line:
--
-- connection:enabletls{protocol = 'sslv3'}
--
-- You can skip this step by creating the connection using
--
-- local connection = imap4('imap.gmail.com', 993, {protocol = 'tlsv1_2'})

-- Print the servers capabilities.
print(table.concat(connection:capability(), ', '))

-- Make sure we can do what we came for.
assert(connection:isCapable('IMAP4rev1'))

-- Login. Warning: The credentials are sent in plaintext unless you
-- tunnel the connection over ssh, or use SSL (either via the method shown
-- above or calling connection:starttls(params) before logging in).
connection:login(user, pass)

-- connection:lsub() lists all subscribed mailboxes.
for mb, info in pairs(connection:lsub()) do
	-- connection:status(mailbox, items) queries status of a mailbox.
	-- Note: The mailbox name may contain unescaped whitespace. You are
	--       responsible to escape it properly - try ("%q"):format(mb).
        if not info.flags["Noselect"] then
            local stat = connection:status(mb, {'MESSAGES', 'RECENT', 'UNSEEN'})
            print(mb, stat.MESSAGES, stat.RECENT, stat.UNSEEN)
        end
end

-- Select INBOX with read only permissions.
local info = connection:examine('INBOX')
print(info.exist, info.recent)

-- List info on the 4 most recent mails.
-- See https://tools.ietf.org/html/rfc3501#section-6.4.5
for _,v in pairs(connection:fetch('(UID BODY.PEEK[HEADER.FIELDS (From Date Subject)])', (info.exist-4)..':*')) do
	-- `v' contains the response as mixed (possibly nested) table.
	-- Keys are stored in the list part. In this example:
	--
	--    v[1] = "UID", v[2] = BODY
	--
	-- `v[key]' holds the value of that part, e.g.
	--
	--    v.UID = 10
	--
	-- `v.BODY' is the only exception and returns a table of the format
	--
	--    {parts = part-table, value = response}
	--
	-- For example:
	--
	--    v.BODY = {
	--        parts = {"HEADER.FIELDS", {"From", "Date", "Subject"}},
	--        value = "From: Foo <foo@bar.baz>\r\nDate:..."
	--    }
	print(v.id, v.UID, v.BODY.value)
end

-- close connection
connection:logout()
