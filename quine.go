package main
import (
"bufio"
"bytes"
"fmt"
"strings"
)
const a = "package main\n" + 
"import (\n" + 
"\"bufio\"\n" + 
"\"bytes\"\n" + 
"\"fmt\"\n" + 
"\"strings\"\n" + 
")\n" + 
"const a = %s\n" + 
"func main() {\n" + 
"\tbuf := &bytes.Buffer{}\n" + 
"\tscanner := bufio.NewScanner(strings.NewReader(a))\n" + 
"\tfor scanner.Scan() {\n" + 
"\t\tfmt.Fprintf(buf, \"%%q + \\n\", scanner.Text() + \"\\n\")\n" + 
"\t}\n" + 
"\tfmt.Fprintf(buf, \"\\\"\\\"\")\n" + 
"\tfmt.Printf(a, buf.String())\n" + 
"}\n" + 
""
func main() {
	buf := &bytes.Buffer{}
	scanner := bufio.NewScanner(strings.NewReader(a))
	for scanner.Scan() {
		fmt.Fprintf(buf, "%q + \n", scanner.Text() + "\n")
	}
	fmt.Fprintf(buf, "\"\"")
	fmt.Printf(a, buf.String())
}
