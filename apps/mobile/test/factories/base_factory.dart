import 'package:faker/faker.dart';

/// Base factory class for all test data factories
///
/// Provides common functionality and patterns for test data generation
/// following 2025 best practices for factory pattern implementation.
abstract class BaseFactory<T> {
  static final Faker faker = Faker();

  /// Create a single instance with optional overrides
  T create({Map<String, dynamic>? overrides}) {
    final defaults = generateDefaults();
    final data = {...defaults, ...?overrides};
    return fromMap(data);
  }

  /// Create multiple instances
  List<T> createBatch(
    int count, {
    Map<String, dynamic>? overrides,
    bool unique = true,
  }) {
    if (!unique) {
      // Create identical instances
      final instance = create(overrides: overrides);
      return List.filled(count, instance);
    }

    // Create unique instances
    return List.generate(
      count,
      (_) => create(overrides: overrides),
    );
  }

  /// Create with relationships
  T createWithRelations({
    Map<String, dynamic>? overrides,
    Map<String, FactoryBuilder>? relations,
  }) {
    final data = {...generateDefaults(), ...?overrides};

    // Build related objects
    relations?.forEach((key, builder) {
      data[key] = builder.build();
    });

    return fromMap(data);
  }

  /// Generate default values for the model
  Map<String, dynamic> generateDefaults();

  /// Convert map to model instance
  T fromMap(Map<String, dynamic> data);

  /// Create a sequence of items with incrementing values
  List<T> createSequence(
    int count, {
    Map<String, dynamic> Function(int index)? modifier,
  }) {
    return List.generate(count, (index) {
      final overrides = modifier?.call(index) ?? {};
      return create(overrides: overrides);
    });
  }

  /// Create with specific state
  T createWithState(FactoryState state) {
    switch (state) {
      case FactoryState.valid:
        return createValid();
      case FactoryState.invalid:
        return createInvalid();
      case FactoryState.minimal:
        return createMinimal();
      case FactoryState.complete:
        return createComplete();
      case FactoryState.empty:
        return createEmpty();
    }
  }

  /// Create a valid instance (can be overridden)
  T createValid() => create();

  /// Create an invalid instance (should be overridden)
  T createInvalid() => create();

  /// Create a minimal instance (should be overridden)
  T createMinimal() => create();

  /// Create a complete instance (should be overridden)
  T createComplete() => create();

  /// Create an empty instance (should be overridden)
  T createEmpty() => create();

  /// Reset any internal state (e.g., counters)
  void reset() {
    // Can be overridden by subclasses
  }

  /// Generate a random ID
  String generateId({String prefix = 'id'}) {
    return '${prefix}_${faker.guid.guid()}';
  }

  /// Generate a random email
  String generateEmail() => faker.internet.email();

  /// Generate a random name
  String generateName() => faker.person.name();

  /// Generate a random phone number
  String generatePhone() => faker.phoneNumber.us();

  /// Generate a random URL
  String generateUrl() => faker.internet.httpsUrl();

  /// Generate random text
  String generateText({int sentences = 1}) {
    return faker.lorem.sentences(sentences).join(' ');
  }

  /// Generate a random date
  DateTime generateDate({
    DateTime? min,
    DateTime? max,
  }) {
    final now = DateTime.now();
    return faker.date.dateTimeBetween(
      min ?? now.subtract(const Duration(days: 365)),
      max ?? now,
    );
  }

  /// Generate a random amount
  double generateAmount({
    double min = 0,
    double max = 1000,
    int decimals = 2,
  }) {
    final amount = faker.randomGenerator.decimal(
      min: min,
      scale: max,
    );
    return double.parse(amount.toStringAsFixed(decimals));
  }

  /// Generate a random boolean
  bool generateBool({double probability = 0.5}) {
    return faker.randomGenerator.decimal() < probability;
  }

  /// Pick a random element from a list
  E pickRandom<E>(List<E> list) {
    return faker.randomGenerator.element(list);
  }

  /// Generate multiple random elements from a list
  List<E> pickMultiple<E>(
    List<E> list, {
    int? count,
    bool allowDuplicates = false,
  }) {
    final itemCount = count ?? faker.randomGenerator.integer(list.length, min: 1);

    if (!allowDuplicates) {
      final shuffled = List<E>.from(list)..shuffle();
      return shuffled.take(itemCount).toList();
    }

    return List.generate(
      itemCount,
      (_) => pickRandom(list),
    );
  }
}

/// Factory builder interface for relationships
abstract class FactoryBuilder<T> {
  T build();
  List<T> buildMany(int count);
}

/// Factory state enumeration
enum FactoryState {
  valid,
  invalid,
  minimal,
  complete,
  empty,
}

/// Simple factory builder implementation
class SimpleFactoryBuilder<T> implements FactoryBuilder<T> {
  final T Function() _builder;
  final List<T> Function(int) _batchBuilder;

  SimpleFactoryBuilder({
    required T Function() builder,
    List<T> Function(int)? batchBuilder,
  })  : _builder = builder,
        _batchBuilder = batchBuilder ?? ((count) => List.generate(count, (_) => builder()));

  @override
  T build() => _builder();

  @override
  List<T> buildMany(int count) => _batchBuilder(count);
}

/// Factory relationship helper
class FactoryRelationship {
  static FactoryBuilder<T> hasOne<T>(BaseFactory<T> factory) {
    return SimpleFactoryBuilder<T>(
      builder: () => factory.create(),
      batchBuilder: (count) => [factory.create()],
    );
  }

  static FactoryBuilder<List<T>> hasMany<T>(
    BaseFactory<T> factory, {
    int count = 3,
  }) {
    return SimpleFactoryBuilder<List<T>>(
      builder: () => factory.createBatch(count),
      batchBuilder: (batchCount) => [factory.createBatch(count)],
    );
  }

  static FactoryBuilder<T?> hasOptional<T>(
    BaseFactory<T> factory, {
    double probability = 0.5,
  }) {
    return SimpleFactoryBuilder<T?>(
      builder: () => BaseFactory.faker.randomGenerator.decimal() < probability
          ? factory.create()
          : null,
    );
  }
}