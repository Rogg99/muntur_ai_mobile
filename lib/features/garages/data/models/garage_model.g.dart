// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garage_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGarageModelCollection on Isar {
  IsarCollection<GarageModel> get garageModels => this.collection();
}

const GarageModelSchema = CollectionSchema(
  name: r'GarageModel',
  id: 8316195633361022318,
  properties: {
    r'description': PropertySchema(
      id: 0,
      name: r'description',
      type: IsarType.string,
    ),
    r'distance': PropertySchema(
      id: 1,
      name: r'distance',
      type: IsarType.double,
    ),
    r'email': PropertySchema(
      id: 2,
      name: r'email',
      type: IsarType.string,
    ),
    r'heureFermeture': PropertySchema(
      id: 3,
      name: r'heureFermeture',
      type: IsarType.string,
    ),
    r'heureOuverture': PropertySchema(
      id: 4,
      name: r'heureOuverture',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 5,
      name: r'id',
      type: IsarType.string,
    ),
    r'latitude': PropertySchema(
      id: 6,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 7,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'medias': PropertySchema(
      id: 8,
      name: r'medias',
      type: IsarType.string,
    ),
    r'nom': PropertySchema(
      id: 9,
      name: r'nom',
      type: IsarType.string,
    ),
    r'pays': PropertySchema(
      id: 10,
      name: r'pays',
      type: IsarType.string,
    ),
    r'photo': PropertySchema(
      id: 11,
      name: r'photo',
      type: IsarType.string,
    ),
    r'rating': PropertySchema(
      id: 12,
      name: r'rating',
      type: IsarType.double,
    ),
    r'stale': PropertySchema(
      id: 13,
      name: r'stale',
      type: IsarType.bool,
    ),
    r'telephone1': PropertySchema(
      id: 14,
      name: r'telephone1',
      type: IsarType.string,
    ),
    r'telephone2': PropertySchema(
      id: 15,
      name: r'telephone2',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 16,
      name: r'type',
      type: IsarType.string,
    ),
    r'ville': PropertySchema(
      id: 17,
      name: r'ville',
      type: IsarType.string,
    )
  },
  estimateSize: _garageModelEstimateSize,
  serialize: _garageModelSerialize,
  deserialize: _garageModelDeserialize,
  deserializeProp: _garageModelDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _garageModelGetId,
  getLinks: _garageModelGetLinks,
  attach: _garageModelAttach,
  version: '3.1.0+1',
);

int _garageModelEstimateSize(
  GarageModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.email.length * 3;
  bytesCount += 3 + object.heureFermeture.length * 3;
  bytesCount += 3 + object.heureOuverture.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.medias.length * 3;
  bytesCount += 3 + object.nom.length * 3;
  bytesCount += 3 + object.pays.length * 3;
  bytesCount += 3 + object.photo.length * 3;
  bytesCount += 3 + object.telephone1.length * 3;
  bytesCount += 3 + object.telephone2.length * 3;
  bytesCount += 3 + object.type.length * 3;
  bytesCount += 3 + object.ville.length * 3;
  return bytesCount;
}

void _garageModelSerialize(
  GarageModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.description);
  writer.writeDouble(offsets[1], object.distance);
  writer.writeString(offsets[2], object.email);
  writer.writeString(offsets[3], object.heureFermeture);
  writer.writeString(offsets[4], object.heureOuverture);
  writer.writeString(offsets[5], object.id);
  writer.writeDouble(offsets[6], object.latitude);
  writer.writeDouble(offsets[7], object.longitude);
  writer.writeString(offsets[8], object.medias);
  writer.writeString(offsets[9], object.nom);
  writer.writeString(offsets[10], object.pays);
  writer.writeString(offsets[11], object.photo);
  writer.writeDouble(offsets[12], object.rating);
  writer.writeBool(offsets[13], object.stale);
  writer.writeString(offsets[14], object.telephone1);
  writer.writeString(offsets[15], object.telephone2);
  writer.writeString(offsets[16], object.type);
  writer.writeString(offsets[17], object.ville);
}

GarageModel _garageModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GarageModel();
  object.description = reader.readString(offsets[0]);
  object.distance = reader.readDouble(offsets[1]);
  object.email = reader.readString(offsets[2]);
  object.heureFermeture = reader.readString(offsets[3]);
  object.heureOuverture = reader.readString(offsets[4]);
  object.id = reader.readString(offsets[5]);
  object.isarId = id;
  object.latitude = reader.readDouble(offsets[6]);
  object.longitude = reader.readDouble(offsets[7]);
  object.medias = reader.readString(offsets[8]);
  object.nom = reader.readString(offsets[9]);
  object.pays = reader.readString(offsets[10]);
  object.photo = reader.readString(offsets[11]);
  object.rating = reader.readDouble(offsets[12]);
  object.stale = reader.readBool(offsets[13]);
  object.telephone1 = reader.readString(offsets[14]);
  object.telephone2 = reader.readString(offsets[15]);
  object.type = reader.readString(offsets[16]);
  object.ville = reader.readString(offsets[17]);
  return object;
}

P _garageModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _garageModelGetId(GarageModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _garageModelGetLinks(GarageModel object) {
  return [];
}

void _garageModelAttach(
    IsarCollection<dynamic> col, Id id, GarageModel object) {
  object.isarId = id;
}

extension GarageModelByIndex on IsarCollection<GarageModel> {
  Future<GarageModel?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  GarageModel? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<GarageModel?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<GarageModel?> getAllByIdSync(List<String> idValues) {
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

  Future<Id> putById(GarageModel object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(GarageModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<GarageModel> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<GarageModel> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension GarageModelQueryWhereSort
    on QueryBuilder<GarageModel, GarageModel, QWhere> {
  QueryBuilder<GarageModel, GarageModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GarageModelQueryWhere
    on QueryBuilder<GarageModel, GarageModel, QWhereClause> {
  QueryBuilder<GarageModel, GarageModel, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterWhereClause> isarIdNotEqualTo(
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

  QueryBuilder<GarageModel, GarageModel, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<GarageModel, GarageModel, QAfterWhereClause> idEqualTo(
      String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterWhereClause> idNotEqualTo(
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
}

extension GarageModelQueryFilter
    on QueryBuilder<GarageModel, GarageModel, QFilterCondition> {
  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> distanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      distanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      distanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> distanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'distance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> emailEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      emailGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> emailLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> emailBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'email',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> emailContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> emailMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'email',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureFermetureEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heureFermeture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureFermetureGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heureFermeture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureFermetureLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heureFermeture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureFermetureBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heureFermeture',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureFermetureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'heureFermeture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureFermetureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'heureFermeture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureFermetureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'heureFermeture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureFermetureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'heureFermeture',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureFermetureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heureFermeture',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureFermetureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'heureFermeture',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureOuvertureEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heureOuverture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureOuvertureGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heureOuverture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureOuvertureLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heureOuverture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureOuvertureBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heureOuverture',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureOuvertureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'heureOuverture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureOuvertureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'heureOuverture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureOuvertureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'heureOuverture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureOuvertureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'heureOuverture',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureOuvertureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heureOuverture',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      heureOuvertureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'heureOuverture',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> idContains(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> idMatches(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> mediasEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      mediasGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'medias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> mediasLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'medias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> mediasBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'medias',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      mediasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'medias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> mediasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'medias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> mediasContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'medias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> mediasMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'medias',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      mediasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medias',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      mediasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'medias',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> nomEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> nomGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> nomLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> nomBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nom',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> nomStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> nomEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> nomContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> nomMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nom',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> nomIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nom',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      nomIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nom',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> paysEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pays',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> paysGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pays',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> paysLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pays',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> paysBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> paysStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pays',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> paysEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pays',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> paysContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pays',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> paysMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pays',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> paysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pays',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      paysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pays',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> photoEqualTo(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> photoLessThan(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> photoBetween(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> photoStartsWith(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> photoEndsWith(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> photoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> photoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> photoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photo',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      photoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photo',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> ratingEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rating',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      ratingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rating',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> ratingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rating',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> ratingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rating',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> staleEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stale',
        value: value,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone1EqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'telephone1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone1GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'telephone1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone1LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'telephone1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone1Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'telephone1',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone1StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'telephone1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone1EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'telephone1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone1Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'telephone1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone1Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'telephone1',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone1IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'telephone1',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone1IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'telephone1',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone2EqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'telephone2',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone2GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'telephone2',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone2LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'telephone2',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone2Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'telephone2',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone2StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'telephone2',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone2EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'telephone2',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone2Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'telephone2',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone2Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'telephone2',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone2IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'telephone2',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      telephone2IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'telephone2',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> typeEqualTo(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> typeGreaterThan(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> typeLessThan(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> typeBetween(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> typeStartsWith(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> typeEndsWith(
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

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> villeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ville',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      villeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ville',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> villeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ville',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> villeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ville',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> villeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ville',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> villeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ville',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> villeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ville',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> villeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ville',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition> villeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ville',
        value: '',
      ));
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterFilterCondition>
      villeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ville',
        value: '',
      ));
    });
  }
}

extension GarageModelQueryObject
    on QueryBuilder<GarageModel, GarageModel, QFilterCondition> {}

extension GarageModelQueryLinks
    on QueryBuilder<GarageModel, GarageModel, QFilterCondition> {}

extension GarageModelQuerySortBy
    on QueryBuilder<GarageModel, GarageModel, QSortBy> {
  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByHeureFermeture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heureFermeture', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy>
      sortByHeureFermetureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heureFermeture', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByHeureOuverture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heureOuverture', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy>
      sortByHeureOuvertureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heureOuverture', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByMedias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medias', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByMediasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medias', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByNom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nom', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByNomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nom', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByPays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pays', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByPaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pays', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByPhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photo', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByPhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photo', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stale', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByStaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stale', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByTelephone1() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telephone1', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByTelephone1Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telephone1', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByTelephone2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telephone2', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByTelephone2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telephone2', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByVille() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ville', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> sortByVilleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ville', Sort.desc);
    });
  }
}

extension GarageModelQuerySortThenBy
    on QueryBuilder<GarageModel, GarageModel, QSortThenBy> {
  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByHeureFermeture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heureFermeture', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy>
      thenByHeureFermetureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heureFermeture', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByHeureOuverture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heureOuverture', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy>
      thenByHeureOuvertureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heureOuverture', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByMedias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medias', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByMediasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medias', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByNom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nom', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByNomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nom', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByPays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pays', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByPaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pays', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByPhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photo', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByPhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photo', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stale', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByStaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stale', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByTelephone1() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telephone1', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByTelephone1Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telephone1', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByTelephone2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telephone2', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByTelephone2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telephone2', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByVille() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ville', Sort.asc);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QAfterSortBy> thenByVilleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ville', Sort.desc);
    });
  }
}

extension GarageModelQueryWhereDistinct
    on QueryBuilder<GarageModel, GarageModel, QDistinct> {
  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distance');
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByHeureFermeture(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heureFermeture',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByHeureOuverture(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heureOuverture',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByMedias(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'medias', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByNom(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nom', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByPays(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pays', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByPhoto(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rating');
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stale');
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByTelephone1(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'telephone1', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByTelephone2(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'telephone2', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GarageModel, GarageModel, QDistinct> distinctByVille(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ville', caseSensitive: caseSensitive);
    });
  }
}

extension GarageModelQueryProperty
    on QueryBuilder<GarageModel, GarageModel, QQueryProperty> {
  QueryBuilder<GarageModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<GarageModel, double, QQueryOperations> distanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distance');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> heureFermetureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heureFermeture');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> heureOuvertureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heureOuverture');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GarageModel, double, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<GarageModel, double, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> mediasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'medias');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> nomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nom');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> paysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pays');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> photoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photo');
    });
  }

  QueryBuilder<GarageModel, double, QQueryOperations> ratingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rating');
    });
  }

  QueryBuilder<GarageModel, bool, QQueryOperations> staleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stale');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> telephone1Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'telephone1');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> telephone2Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'telephone2');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<GarageModel, String, QQueryOperations> villeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ville');
    });
  }
}
