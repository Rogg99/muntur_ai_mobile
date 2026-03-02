// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMessageModelCollection on Isar {
  IsarCollection<MessageModel> get messageModels => this.collection();
}

const MessageModelSchema = CollectionSchema(
  name: r'MessageModel',
  id: -902762555029995869,
  properties: {
    r'announced': PropertySchema(
      id: 0,
      name: r'announced',
      type: IsarType.string,
    ),
    r'answerTo': PropertySchema(
      id: 1,
      name: r'answerTo',
      type: IsarType.string,
    ),
    r'contenu': PropertySchema(
      id: 2,
      name: r'contenu',
      type: IsarType.string,
    ),
    r'dateEnvoi': PropertySchema(
      id: 3,
      name: r'dateEnvoi',
      type: IsarType.dateTime,
    ),
    r'discId': PropertySchema(
      id: 4,
      name: r'discId',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 5,
      name: r'id',
      type: IsarType.string,
    ),
    r'isAI': PropertySchema(
      id: 6,
      name: r'isAI',
      type: IsarType.bool,
    ),
    r'media': PropertySchema(
      id: 7,
      name: r'media',
      type: IsarType.string,
    ),
    r'mediaName': PropertySchema(
      id: 8,
      name: r'mediaName',
      type: IsarType.string,
    ),
    r'mediaSize': PropertySchema(
      id: 9,
      name: r'mediaSize',
      type: IsarType.string,
    ),
    r'messageState': PropertySchema(
      id: 10,
      name: r'messageState',
      type: IsarType.string,
    ),
    r'pendingSync': PropertySchema(
      id: 11,
      name: r'pendingSync',
      type: IsarType.bool,
    ),
    r'senderId': PropertySchema(
      id: 12,
      name: r'senderId',
      type: IsarType.string,
    ),
    r'senderName': PropertySchema(
      id: 13,
      name: r'senderName',
      type: IsarType.string,
    ),
    r'senderPhoto': PropertySchema(
      id: 14,
      name: r'senderPhoto',
      type: IsarType.string,
    ),
    r'tempId': PropertySchema(
      id: 15,
      name: r'tempId',
      type: IsarType.string,
    )
  },
  estimateSize: _messageModelEstimateSize,
  serialize: _messageModelSerialize,
  deserialize: _messageModelDeserialize,
  deserializeProp: _messageModelDeserializeProp,
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
    r'discId': IndexSchema(
      id: -2436079580361122913,
      name: r'discId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'discId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _messageModelGetId,
  getLinks: _messageModelGetLinks,
  attach: _messageModelAttach,
  version: '3.1.0+1',
);

int _messageModelEstimateSize(
  MessageModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.announced.length * 3;
  bytesCount += 3 + object.answerTo.length * 3;
  bytesCount += 3 + object.contenu.length * 3;
  bytesCount += 3 + object.discId.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.media.length * 3;
  bytesCount += 3 + object.mediaName.length * 3;
  bytesCount += 3 + object.mediaSize.length * 3;
  bytesCount += 3 + object.messageState.length * 3;
  bytesCount += 3 + object.senderId.length * 3;
  bytesCount += 3 + object.senderName.length * 3;
  bytesCount += 3 + object.senderPhoto.length * 3;
  bytesCount += 3 + object.tempId.length * 3;
  return bytesCount;
}

void _messageModelSerialize(
  MessageModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.announced);
  writer.writeString(offsets[1], object.answerTo);
  writer.writeString(offsets[2], object.contenu);
  writer.writeDateTime(offsets[3], object.dateEnvoi);
  writer.writeString(offsets[4], object.discId);
  writer.writeString(offsets[5], object.id);
  writer.writeBool(offsets[6], object.isAI);
  writer.writeString(offsets[7], object.media);
  writer.writeString(offsets[8], object.mediaName);
  writer.writeString(offsets[9], object.mediaSize);
  writer.writeString(offsets[10], object.messageState);
  writer.writeBool(offsets[11], object.pendingSync);
  writer.writeString(offsets[12], object.senderId);
  writer.writeString(offsets[13], object.senderName);
  writer.writeString(offsets[14], object.senderPhoto);
  writer.writeString(offsets[15], object.tempId);
}

MessageModel _messageModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MessageModel();
  object.announced = reader.readString(offsets[0]);
  object.answerTo = reader.readString(offsets[1]);
  object.contenu = reader.readString(offsets[2]);
  object.dateEnvoi = reader.readDateTime(offsets[3]);
  object.discId = reader.readString(offsets[4]);
  object.id = reader.readString(offsets[5]);
  object.isAI = reader.readBool(offsets[6]);
  object.isarId = id;
  object.media = reader.readString(offsets[7]);
  object.mediaName = reader.readString(offsets[8]);
  object.mediaSize = reader.readString(offsets[9]);
  object.messageState = reader.readString(offsets[10]);
  object.pendingSync = reader.readBool(offsets[11]);
  object.senderId = reader.readString(offsets[12]);
  object.senderName = reader.readString(offsets[13]);
  object.senderPhoto = reader.readString(offsets[14]);
  object.tempId = reader.readString(offsets[15]);
  return object;
}

P _messageModelDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _messageModelGetId(MessageModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _messageModelGetLinks(MessageModel object) {
  return [];
}

void _messageModelAttach(
    IsarCollection<dynamic> col, Id id, MessageModel object) {
  object.isarId = id;
}

extension MessageModelByIndex on IsarCollection<MessageModel> {
  Future<MessageModel?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  MessageModel? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<MessageModel?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<MessageModel?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(MessageModel object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(MessageModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<MessageModel> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<MessageModel> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension MessageModelQueryWhereSort
    on QueryBuilder<MessageModel, MessageModel, QWhere> {
  QueryBuilder<MessageModel, MessageModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MessageModelQueryWhere
    on QueryBuilder<MessageModel, MessageModel, QWhereClause> {
  QueryBuilder<MessageModel, MessageModel, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
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

  QueryBuilder<MessageModel, MessageModel, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<MessageModel, MessageModel, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterWhereClause> idNotEqualTo(
      String id) {
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

  QueryBuilder<MessageModel, MessageModel, QAfterWhereClause> discIdEqualTo(
      String discId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'discId',
        value: [discId],
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterWhereClause> discIdNotEqualTo(
      String discId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'discId',
              lower: [],
              upper: [discId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'discId',
              lower: [discId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'discId',
              lower: [discId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'discId',
              lower: [],
              upper: [discId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MessageModelQueryFilter
    on QueryBuilder<MessageModel, MessageModel, QFilterCondition> {
  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      announcedEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'announced',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      announcedGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'announced',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      announcedLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'announced',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      announcedBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'announced',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      announcedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'announced',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      announcedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'announced',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      announcedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'announced',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      announcedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'announced',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      announcedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'announced',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      announcedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'announced',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      answerToEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answerTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      answerToGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'answerTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      answerToLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'answerTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      answerToBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'answerTo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      answerToStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'answerTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      answerToEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'answerTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      answerToContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'answerTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      answerToMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'answerTo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      answerToIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answerTo',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      answerToIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'answerTo',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      contenuEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contenu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      contenuGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contenu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      contenuLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contenu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      contenuBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contenu',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      contenuStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contenu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      contenuEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contenu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      contenuContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contenu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      contenuMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contenu',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      contenuIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contenu',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      contenuIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contenu',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      dateEnvoiEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateEnvoi',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      dateEnvoiGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateEnvoi',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      dateEnvoiLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateEnvoi',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      dateEnvoiBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateEnvoi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> discIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      discIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      discIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> discIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      discIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'discId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      discIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'discId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      discIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'discId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> discIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'discId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      discIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      discIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'discId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> isAIEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAI',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
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

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
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

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> mediaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'media',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'media',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> mediaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'media',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> mediaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'media',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'media',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> mediaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'media',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> mediaContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'media',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> mediaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'media',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'media',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'media',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaName',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaName',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaSizeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaSizeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaSizeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaSizeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaSizeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaSizeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaSizeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaSizeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaSize',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaSizeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaSize',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      mediaSizeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaSize',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      messageStateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      messageStateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      messageStateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      messageStateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageState',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      messageStateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'messageState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      messageStateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'messageState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      messageStateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'messageState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      messageStateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'messageState',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      messageStateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageState',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      messageStateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'messageState',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      pendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendingSync',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderName',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderName',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderPhotoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderPhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderPhotoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderPhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderPhotoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderPhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderPhotoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderPhoto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderPhotoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderPhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderPhotoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderPhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderPhotoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderPhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderPhotoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderPhoto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderPhotoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderPhoto',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      senderPhotoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderPhoto',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> tempIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tempId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      tempIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tempId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      tempIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tempId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> tempIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tempId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      tempIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tempId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      tempIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tempId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      tempIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tempId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition> tempIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tempId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      tempIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tempId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterFilterCondition>
      tempIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tempId',
        value: '',
      ));
    });
  }
}

extension MessageModelQueryObject
    on QueryBuilder<MessageModel, MessageModel, QFilterCondition> {}

extension MessageModelQueryLinks
    on QueryBuilder<MessageModel, MessageModel, QFilterCondition> {}

extension MessageModelQuerySortBy
    on QueryBuilder<MessageModel, MessageModel, QSortBy> {
  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByAnnounced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'announced', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByAnnouncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'announced', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByAnswerTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answerTo', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByAnswerToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answerTo', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByContenu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contenu', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByContenuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contenu', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByDateEnvoi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateEnvoi', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByDateEnvoiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateEnvoi', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByDiscId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discId', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByDiscIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discId', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByIsAI() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAI', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByIsAIDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAI', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByMedia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'media', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByMediaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'media', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByMediaName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaName', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByMediaNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaName', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByMediaSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaSize', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByMediaSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaSize', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByMessageState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageState', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy>
      sortByMessageStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageState', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy>
      sortByPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortBySenderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy>
      sortBySenderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortBySenderPhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderPhoto', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy>
      sortBySenderPhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderPhoto', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByTempId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tempId', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> sortByTempIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tempId', Sort.desc);
    });
  }
}

extension MessageModelQuerySortThenBy
    on QueryBuilder<MessageModel, MessageModel, QSortThenBy> {
  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByAnnounced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'announced', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByAnnouncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'announced', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByAnswerTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answerTo', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByAnswerToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answerTo', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByContenu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contenu', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByContenuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contenu', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByDateEnvoi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateEnvoi', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByDateEnvoiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateEnvoi', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByDiscId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discId', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByDiscIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discId', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByIsAI() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAI', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByIsAIDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAI', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByMedia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'media', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByMediaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'media', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByMediaName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaName', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByMediaNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaName', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByMediaSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaSize', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByMediaSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaSize', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByMessageState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageState', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy>
      thenByMessageStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageState', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy>
      thenByPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenBySenderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy>
      thenBySenderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenBySenderPhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderPhoto', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy>
      thenBySenderPhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderPhoto', Sort.desc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByTempId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tempId', Sort.asc);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QAfterSortBy> thenByTempIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tempId', Sort.desc);
    });
  }
}

extension MessageModelQueryWhereDistinct
    on QueryBuilder<MessageModel, MessageModel, QDistinct> {
  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctByAnnounced(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'announced', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctByAnswerTo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'answerTo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctByContenu(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contenu', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctByDateEnvoi() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateEnvoi');
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctByDiscId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctByIsAI() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAI');
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctByMedia(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'media', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctByMediaName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctByMediaSize(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaSize', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctByMessageState(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageState', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingSync');
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctBySenderId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctBySenderName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctBySenderPhoto(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderPhoto', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageModel, MessageModel, QDistinct> distinctByTempId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tempId', caseSensitive: caseSensitive);
    });
  }
}

extension MessageModelQueryProperty
    on QueryBuilder<MessageModel, MessageModel, QQueryProperty> {
  QueryBuilder<MessageModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> announcedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'announced');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> answerToProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'answerTo');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> contenuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contenu');
    });
  }

  QueryBuilder<MessageModel, DateTime, QQueryOperations> dateEnvoiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateEnvoi');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> discIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discId');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MessageModel, bool, QQueryOperations> isAIProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAI');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> mediaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'media');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> mediaNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaName');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> mediaSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaSize');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> messageStateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageState');
    });
  }

  QueryBuilder<MessageModel, bool, QQueryOperations> pendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingSync');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> senderNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderName');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> senderPhotoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderPhoto');
    });
  }

  QueryBuilder<MessageModel, String, QQueryOperations> tempIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tempId');
    });
  }
}
