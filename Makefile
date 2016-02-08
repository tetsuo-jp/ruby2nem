doc/NEM.html: NEM.rb
	yardoc NEM.rb

server: doc/NEM.html
	open http://localhost:8808/docs/NEM
	yard server
