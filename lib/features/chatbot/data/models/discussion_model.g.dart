// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDiscussionModelCollection on Isar {
  IsarCollection<DiscussionModel> get discussionModels => this.collection();
}

const DiscussionModelSchema = CollectionSchema(
  name: r'DiscussionModel',
  id: -4716185525125129118,
  properties: {
    r'id': PropertySchema(
      id: 0,
      name: r'id',
      type: IsarType.string,
    ),
    r'initiateur': PropertySchema(
      id: 1,
      name: r'initiateur',
      type: IsarType.string,
    ),
    r'interlocuteur': PropertySchema(
      id: 2,
      name: r'interlocuteur',
      type: IsarType.string,
    ),
    r'last_check': PropertySchema(
      id: 3,
      name: r'last_check',
      type: IsarType.long,
    ),
    r'last_date': PropertySchema(
      id: 4,
      name: r'last_date',
      type: IsarType.string,
    ),
    r'last_message': PropertySchema(
      id: 5,
      name: r'last_message',
      type: IsarType.string,
    ),
    r'last_writer': PropertySchema(
      id: 6,
      name: r'last_writer',
      type: IsarType.string,
    ),
    r'pendingSync': PropertySchema(
      id: 7,
      name: r'pendingSync',
      type: IsarType.bool,
    ),
    r'photo': PropertySchema(
      id: 8,
      name: r'photo',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 9,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 10,
      name: r'type',
      type: IsarType.string,
    ),
    r'unreadCount': PropertySchema(
      id: 11,
      name: r'unreadCount',
      type: IsarType.long,
    )
  },
  estimateSize: _discussionModelEstimateSize,
  serialize: _discussionModelSerialize,
  deserialize: _discussionModelDeserialize,
  deserializeProp: _discussionModelDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'type': IndexSchema(
      id: 5117122708147080838,
      name: r'type',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'type',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _discussionModelGetId,
  getLinks: _discussionModelGetLinks,
  attach: _discussionModelAttach,
  version: '3.1.0+1',
);

int _discussionModelEstimateSize(
  DiscussionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.initiateur.length * 3;
  bytesCount += 3 + object.interlocuteur.length * 3;
  bytesCount += 3 + object.last_date.length * 3;
  bytesCount += 3 + object.last_message.length * 3;
  bytesCount += 3 + object.last_writer.length * 3;
  bytesCount += 3 + object.photo.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _discussionModelSerialize(
  DiscussionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.id);
  writer.writeString(offsets[1], object.initiateur);
  writer.writeString(offsets[2], object.interlocuteur);
  writer.writeLong(offsets[3], object.last_check);
  writer.writeString(offsets[4], object.last_date);
  writer.writeString(offsets[5], object.last_message);
  writer.writeString(offsets[6], object.last_writer);
  writer.writeBool(offsets[7], object.pendingSync);
  writer.writeString(offsets[8], object.photo);
  writer.writeString(offsets[9], object.title);
  writer.writeString(offsets[10], object.type);
  writer.writeLong(offsets[11], object.unreadCount);
}

DiscussionModel _discussionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DiscussionModel();
  object.id = reader.readString(offsets[0]);
  object.initiateur = reader.readString(offsets[1]);
  object.interlocuteur = reader.readString(offsets[2]);
  object.isarId = id;
  object.last_check = reader.readLong(offsets[3]);
  object.last_date = reader.readString(offsets[4]);
  object.last_message = reader.readString(offsets[5]);
  object.last_writer = reader.readString(offsets[6]);
  object.pendingSync = reader.readBool(offsets[7]);
  object.photo = reader.readString(offsets[8]);
  object.title = reader.readString(offsets[9]);
  object.type = reader.readString(offsets[10]);
  object.unreadCount = reader.readLong(offsets[11]);
  return object;
}

P _discussionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _discussionModelGetId(DiscussionModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _discussionModelGetLinks(DiscussionModel object) {
  return [];
}

void _discussionModelAttach(
    IsarCollection<dynamic> col, Id id, DiscussionModel object) {
  object.isarId = id;
}

extension DiscussionModelByIndex on IsarCollection<DiscussionModel> {
  Future<DiscussionModel?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  DiscussionModel? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<DiscussionModel?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<DiscussionModel?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(DiscussionModel object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(DiscussionModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<DiscussionModel> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<DiscussionModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension DiscussionModelQueryWhereSort
    on QueryBuilder<DiscussionModel, DiscussionModel, QWhere> {
  QueryBuilder<DiscussionModel, DiscussionModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DiscussionModelQueryWhere
    on QueryBuilder<DiscussionModel, DiscussionModel, QWhereClause> {
  QueryBuilder<DiscussionModel, DiscussionModel, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterWhereClause>
      idNotEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterWhereClause> typeEqualTo(
      String type) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'type',
        value: [type],
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterWhereClause>
      typeNotEqualTo(String type) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [],
              upper: [type],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [type],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [type],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [],
              upper: [type],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DiscussionModelQueryFilter
    on QueryBuilder<DiscussionModel, DiscussionModel, QFilterCondition> {
  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      initiateurEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initiateur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      initiateurGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'initiateur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      initiateurLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'initiateur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      initiateurBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'initiateur',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      initiateurStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'initiateur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      initiateurEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'initiateur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      initiateurContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'initiateur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      initiateurMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'initiateur',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      initiateurIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initiateur',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      initiateurIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'initiateur',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      interlocuteurEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interlocuteur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      interlocuteurGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interlocuteur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      interlocuteurLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interlocuteur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      interlocuteurBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interlocuteur',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      interlocuteurStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'interlocuteur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      interlocuteurEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'interlocuteur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      interlocuteurContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'interlocuteur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      interlocuteurMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'interlocuteur',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      interlocuteurIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interlocuteur',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      interlocuteurIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'interlocuteur',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_checkEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'last_check',
        value: value,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_checkGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'last_check',
        value: value,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_checkLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'last_check',
        value: value,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_checkBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'last_check',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_dateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'last_date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_dateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'last_date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_dateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'last_date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_dateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'last_date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_dateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'last_date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_dateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'last_date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_dateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'last_date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_dateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'last_date',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'last_date',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'last_date',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_messageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'last_message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_messageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'last_message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_messageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'last_message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_messageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'last_message',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_messageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'last_message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_messageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'last_message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_messageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'last_message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_messageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'last_message',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_messageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'last_message',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_messageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'last_message',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_writerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'last_writer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_writerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'last_writer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_writerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'last_writer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_writerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'last_writer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_writerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'last_writer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_writerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'last_writer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_writerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'last_writer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_writerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'last_writer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_writerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'last_writer',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      last_writerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'last_writer',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      pendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendingSync',
        value: value,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      photoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      photoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      photoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      photoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      photoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      photoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      photoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      photoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      photoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photo',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      photoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photo',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      unreadCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unreadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      unreadCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unreadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      unreadCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unreadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterFilterCondition>
      unreadCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unreadCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DiscussionModelQueryObject
    on QueryBuilder<DiscussionModel, DiscussionModel, QFilterCondition> {}

extension DiscussionModelQueryLinks
    on QueryBuilder<DiscussionModel, DiscussionModel, QFilterCondition> {}

extension DiscussionModelQuerySortBy
    on QueryBuilder<DiscussionModel, DiscussionModel, QSortBy> {
  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByInitiateur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiateur', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByInitiateurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiateur', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByInterlocuteur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interlocuteur', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByInterlocuteurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interlocuteur', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByLast_check() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_check', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByLast_checkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_check', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByLast_date() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_date', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByLast_dateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_date', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByLast_message() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_message', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByLast_messageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_message', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByLast_writer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_writer', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByLast_writerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_writer', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy> sortByPhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photo', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByPhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photo', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      sortByUnreadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.desc);
    });
  }
}

extension DiscussionModelQuerySortThenBy
    on QueryBuilder<DiscussionModel, DiscussionModel, QSortThenBy> {
  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByInitiateur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiateur', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByInitiateurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initiateur', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByInterlocuteur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interlocuteur', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByInterlocuteurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interlocuteur', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByLast_check() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_check', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByLast_checkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_check', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByLast_date() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_date', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByLast_dateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_date', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByLast_message() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_message', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByLast_messageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_message', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByLast_writer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_writer', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByLast_writerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'last_writer', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy> thenByPhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photo', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByPhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photo', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.asc);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QAfterSortBy>
      thenByUnreadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.desc);
    });
  }
}

extension DiscussionModelQueryWhereDistinct
    on QueryBuilder<DiscussionModel, DiscussionModel, QDistinct> {
  QueryBuilder<DiscussionModel, DiscussionModel, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QDistinct>
      distinctByInitiateur({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initiateur', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QDistinct>
      distinctByInterlocuteur({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interlocuteur',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QDistinct>
      distinctByLast_check() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'last_check');
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QDistinct> distinctByLast_date(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'last_date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QDistinct>
      distinctByLast_message({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'last_message', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QDistinct>
      distinctByLast_writer({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'last_writer', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QDistinct>
      distinctByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingSync');
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QDistinct> distinctByPhoto(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiscussionModel, DiscussionModel, QDistinct>
      distinctByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unreadCount');
    });
  }
}

extension DiscussionModelQueryProperty
    on QueryBuilder<DiscussionModel, DiscussionModel, QQueryProperty> {
  QueryBuilder<DiscussionModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<DiscussionModel, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DiscussionModel, String, QQueryOperations> initiateurProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initiateur');
    });
  }

  QueryBuilder<DiscussionModel, String, QQueryOperations>
      interlocuteurProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interlocuteur');
    });
  }

  QueryBuilder<DiscussionModel, int, QQueryOperations> last_checkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'last_check');
    });
  }

  QueryBuilder<DiscussionModel, String, QQueryOperations> last_dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'last_date');
    });
  }

  QueryBuilder<DiscussionModel, String, QQueryOperations>
      last_messageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'last_message');
    });
  }

  QueryBuilder<DiscussionModel, String, QQueryOperations>
      last_writerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'last_writer');
    });
  }

  QueryBuilder<DiscussionModel, bool, QQueryOperations> pendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingSync');
    });
  }

  QueryBuilder<DiscussionModel, String, QQueryOperations> photoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photo');
    });
  }

  QueryBuilder<DiscussionModel, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<DiscussionModel, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<DiscussionModel, int, QQueryOperations> unreadCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unreadCount');
    });
  }
}
