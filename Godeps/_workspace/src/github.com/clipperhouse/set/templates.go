package set

import "github.com/clipperhouse/typewriter"

var templates = typewriter.TemplateSlice{
	set,
}

var set = &typewriter.Template{
	Name: "Set",
	Text: `
// {{.Name}}Set is the primary type that represents a set
type {{.Name}}Set map[{{.Pointer}}{{.Name}}]struct{}

// New{{.Name}}Set creates and returns a reference to an empty set.
func New{{.Name}}Set(a ...{{.Pointer}}{{.Name}}) {{.Name}}Set {
	s := make({{.Name}}Set)
	for _, i := range a {
		s.Add(i)
	}
	return s
}

// ToSlice returns the elements of the current set as a slice
func (set {{.Name}}Set) ToSlice() []{{.Pointer}}{{.Name}} {
	var s []{{.Pointer}}{{.Name}}
	for v := range set {
		s = append(s, v)
	}
	return s
}

// Add adds an item to the current set if it doesn't already exist in the set.
func (set {{.Name}}Set) Add(i {{.Pointer}}{{.Name}}) bool {
	_, found := set[i]
	set[i] = struct{}{}
	return !found //False if it existed already
}

// Contains determines if a given item is already in the set.
func (set {{.Name}}Set) Contains(i {{.Pointer}}{{.Name}}) bool {
	_, found := set[i]
	return found
}

// ContainsAll determines if the given items are all in the set
func (set {{.Name}}Set) ContainsAll(i ...{{.Pointer}}{{.Name}}) bool {
	for _, v := range i {
		if !set.Contains(v) {
			return false
		}
	}
	return true
}

// IsSubset determines if every item in the other set is in this set.
func (set {{.Name}}Set) IsSubset(other {{.Name}}Set) bool {
	for elem := range set {
		if !other.Contains(elem) {
			return false
		}
	}
	return true
}

// IsSuperset determines if every item of this set is in the other set.
func (set {{.Name}}Set) IsSuperset(other {{.Name}}Set) bool {
	return other.IsSubset(set)
}

// Union returns a new set with all items in both sets.
func (set {{.Name}}Set) Union(other {{.Name}}Set) {{.Name}}Set {
	unionedSet := New{{.Name}}Set()

	for elem := range set {
		unionedSet.Add(elem)
	}
	for elem := range other {
		unionedSet.Add(elem)
	}
	return unionedSet
}

// Intersect returns a new set with items that exist only in both sets.
func (set {{.Name}}Set) Intersect(other {{.Name}}Set) {{.Name}}Set {
	intersection := New{{.Name}}Set()
	// loop over smaller set
	if set.Cardinality() < other.Cardinality() {
		for elem := range set {
			if other.Contains(elem) {
				intersection.Add(elem)
			}
		}
	} else {
		for elem := range other {
			if set.Contains(elem) {
				intersection.Add(elem)
			}
		}
	}
	return intersection
}

// Difference returns a new set with items in the current set but not in the other set
func (set {{.Name}}Set) Difference(other {{.Name}}Set) {{.Name}}Set {
	differencedSet := New{{.Name}}Set()
	for elem := range set {
		if !other.Contains(elem) {
			differencedSet.Add(elem)
		}
	}
	return differencedSet
}

// SymmetricDifference returns a new set with items in the current set or the other set but not in both.
func (set {{.Name}}Set) SymmetricDifference(other {{.Name}}Set) {{.Name}}Set {
	aDiff := set.Difference(other)
	bDiff := other.Difference(set)
	return aDiff.Union(bDiff)
}

// Clear clears the entire set to be the empty set.
func (set *{{.Name}}Set) Clear() {
	*set = make({{.Name}}Set)
}

// Remove allows the removal of a single item in the set.
func (set {{.Name}}Set) Remove(i {{.Pointer}}{{.Name}}) {
	delete(set, i)
}

// Cardinality returns how many items are currently in the set.
func (set {{.Name}}Set) Cardinality() int {
	return len(set)
}

// Iter returns a channel of type {{.Pointer}}{{.Name}} that you can range over.
func (set {{.Name}}Set) Iter() <-chan {{.Pointer}}{{.Name}} {
	ch := make(chan {{.Pointer}}{{.Name}})
	go func() {
		for elem := range set {
			ch <- elem
		}
		close(ch)
	}()

	return ch
}

// Equal determines if two sets are equal to each other.
// If they both are the same size and have the same items they are considered equal.
// Order of items is not relevent for sets to be equal.
func (set {{.Name}}Set) Equal(other {{.Name}}Set) bool {
	if set.Cardinality() != other.Cardinality() {
		return false
	}
	for elem := range set {
		if !other.Contains(elem) {
			return false
		}
	}
	return true
}

// Clone returns a clone of the set.
// Does NOT clone the underlying elements.
func (set {{.Name}}Set) Clone() {{.Name}}Set {
	clonedSet := New{{.Name}}Set()
	for elem := range set {
		clonedSet.Add(elem)
	}
	return clonedSet
}
`,
	TypeConstraint: typewriter.Constraint{Comparable: true},
}
