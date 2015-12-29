package typewriter

import (
	"bytes"
	"fmt"
	"go/parser"
	"go/token"
	"io"
	"os"
	"path/filepath"
	"strings"
	"text/template"

	"golang.org/x/tools/imports"
)

// App is the high-level construct for package-level code generation. Typical usage is along the lines of:
//	app, err := typewriter.NewApp()
//	err := app.WriteAll()
//
// +test foo:"Bar" baz:"qux[struct{}],thing"
type App struct {
	// All typewriter.Package found in the current directory.
	Packages []*Package
	// All typewriter.Interface's registered on init.
	TypeWriters []Interface
	Directive   string
}

// NewApp parses the current directory, enumerating registered TypeWriters and collecting Types and their related information.
func NewApp(directive string) (*App, error) {
	return DefaultConfig.NewApp(directive)
}

func (conf *Config) NewApp(directive string) (*App, error) {
	a := &App{
		Directive:   directive,
		TypeWriters: typeWriters,
	}

	pkgs, err := getPackages(directive, conf)

	a.Packages = pkgs
	return a, err
}

// NewAppFiltered parses the current directory, collecting Types and their related information. Pass a filter to limit which files are operated on.
func NewAppFiltered(directive string, filter func(os.FileInfo) bool) (*App, error) {
	conf := &Config{
		Filter: filter,
	}
	return conf.NewApp(directive)
}

// Individual TypeWriters register on init, keyed by name
var typeWriters []Interface

// Register allows template packages to make themselves known to a 'parent' package, usually in the init() func.
// Comparable to the approach taken by stdlib's image package for registration of image types (eg image/png).
// Your program will do something like:
//	import (
//		"github.com/clipperhouse/typewriter"
//		_ "github.com/clipperhouse/slice"
//	)
func Register(tw Interface) error {
	for _, v := range typeWriters {
		if v.Name() == tw.Name() {
			return fmt.Errorf("A TypeWriter by the name %s has already been registered", tw.Name())
		}
	}
	typeWriters = append(typeWriters, tw)
	return nil
}

// WriteAll writes the generated code for all Types and TypeWriters in the App to respective files.
func (a *App) WriteAll() ([]string, error) {
	var written []string

	// one buffer for each file, keyed by file name
	buffers := make(map[string]*bytes.Buffer)

	// write the generated code for each Type & TypeWriter into memory
	for _, p := range a.Packages {
		for _, t := range p.Types {
			for _, tw := range a.TypeWriters {
				var b bytes.Buffer
				n, err := write(&b, a, p, t, tw)

				if err != nil {
					return written, err
				}

				// don't generate a file if no bytes were written by WriteHeader or WriteBody
				if n == 0 {
					continue
				}

				// append _test to file name if the source type is in a _test.go file
				f := strings.ToLower(fmt.Sprintf("%s_%s%s.go", t.Name, tw.Name(), t.test))

				buffers[f] = &b
			}
		}
	}

	// validate generated ast's before committing to files
	for f, b := range buffers {
		if _, err := parser.ParseFile(token.NewFileSet(), f, b.String(), 0); err != nil {
			// TODO: prompt to write (ignored) _file on error? parsing errors are meaningless without.
			return written, err
		}
	}

	// format, remove unused imports, and commit to files
	for f, b := range buffers {
		src, err := imports.Process(f, b.Bytes(), nil)

		// shouldn't be an error if the ast parsing above succeeded
		if err != nil {
			return written, err
		}

		if err := writeFile(f, src); err != nil {
			return written, err
		}

		written = append(written, f)
	}

	return written, nil
}

var twoLines = bytes.Repeat([]byte{'\n'}, 2)

func write(w *bytes.Buffer, a *App, p *Package, t Type, tw Interface) (n int, err error) {
	// start with byline at top, give future readers some background
	// on where the file came from
	bylineFmt := `// Generated by: %s
// TypeWriter: %s
// Directive: %s on %s`

	caller := filepath.Base(os.Args[0])
	byline := fmt.Sprintf(bylineFmt, caller, tw.Name(), a.Directive, t.String())
	w.Write([]byte(byline))
	w.Write(twoLines)

	// add a package declaration
	pkg := fmt.Sprintf("package %s", p.Name())
	w.Write([]byte(pkg))
	w.Write(twoLines)

	if err := importsTmpl.Execute(w, tw.Imports(t)); err != nil {
		return n, err
	}

	c := countingWriter{0, w}
	err = tw.Write(&c, t)
	n += c.n

	return n, err
}

func writeFile(filename string, byts []byte) error {
	w, err := os.Create(filename)

	if err != nil {
		return err
	}

	defer w.Close()

	w.Write(byts)

	return nil
}

var importsTmpl = template.Must(template.New("imports").Parse(`{{if gt (len .) 0}}
import ({{range .}}
	{{.Name}} "{{.Path}}"{{end}}
)
{{end}}
`))

// a writer that knows how much writing it did
// https://groups.google.com/forum/#!topic/golang-nuts/VQLtfRGqK8Q
type countingWriter struct {
	n int
	w io.Writer
}

func (c *countingWriter) Write(p []byte) (n int, err error) {
	n, err = c.w.Write(p)
	c.n += n
	return
}
