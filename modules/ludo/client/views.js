boardDef = [
    '....www....',
    '....wgw....',
    '....wgw....',
    '....wgw....',
    'wwwwwgwwwww',
    'wrrrrByyyyw',
    'wwwwwbwwwww',
    '....wbw....',
    '....wbw....',
    '....wbw....',
    '....www....'
];

fieldClasses = {
    '.': '',
    'w': 'path',
    'r': 'path red',
    'g': 'path green',
    'y': 'path yellow',
    'b': 'path blue',
    'B': 'path black'
};

Template.LudoBoard.helpers({
    fieldClasses: function (field) {
        var fieldDef = boardDef[field.row][field.column];
        return fieldClasses[fieldDef];
    }
});
