interface INumberIndexedDictionary<T> {
    [index: number]: T
}

interface IBoardViewConfiguration {
    boardClassName: string
    pieceClassName: string
    fieldTypeToCssClass: INumberIndexedDictionary<string>
    pieceColorToCssClass: INumberIndexedDictionary<string>
}

export = IBoardViewConfiguration
