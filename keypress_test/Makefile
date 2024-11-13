all: clean build run

build:
	@echo "Building the project..."
	dune build

# takes the main executable from the dune file 
run:
	@echo "Running the project..."
	dune exec ./_build/default/src/main.exe

clean:
	@echo "Cleaning up..."
	dune clean
