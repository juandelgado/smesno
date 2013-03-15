class Log
	def self.l(txt)
		puts txt
		begin
			log = File.open("log.txt", "a")
			log.write("#{txt}\n");
		rescue
			# nothing to do here
		end
	end
end