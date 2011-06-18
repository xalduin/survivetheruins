#Automatically generates a import.j file that imports all *.j files in the src/ folder

def lookup(folder)
	result = []
	Dir.foreach(folder) do |file|
		if file.match(".j") then
			puts folder + "/" + file
			result << (folder + "/" + file)
		elsif File.directory?(folder + "/" + file) and not file.start_with?(".") then
			result += lookup(folder + "/" + file)
		end
	end
	result
end

files = lookup("src")
out = File.new("import.j", "w")
files.each do |file|
	out.write "//! import \"" + file + "\"\n"
end