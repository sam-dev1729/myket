import '../../../features/profile/data/models/geo_models.dart';

/// Returns the seeded country list.
List<Country> mockSeedCountries() => const [
  Country(id: 'mock-country-iran', name: 'ایران'),
  Country(id: 'mock-country-turkey', name: 'ترکیه'),
];

/// Returns the seeded province list.
List<Province> mockSeedProvinces() => const [
  Province(id: 'mock-province-tehran', name: 'تهران', countryId: 'mock-country-iran'),
  Province(id: 'mock-province-isfahan', name: 'اصفهان', countryId: 'mock-country-iran'),
  Province(id: 'mock-province-fars', name: 'فارس', countryId: 'mock-country-iran'),
  Province(id: 'mock-province-istanbul', name: 'استانبول', countryId: 'mock-country-turkey'),
];

/// Returns the seeded city list.
List<City> mockSeedCities() => const [
  City(id: 'mock-city-tehran', name: 'تهران', provinceId: 'mock-province-tehran'),
  City(id: 'mock-city-shahriar', name: 'شهریار', provinceId: 'mock-province-tehran'),
  City(id: 'mock-city-isfahan', name: 'اصفهان', provinceId: 'mock-province-isfahan'),
  City(id: 'mock-city-shiraz', name: 'شیراز', provinceId: 'mock-province-fars'),
  City(id: 'mock-city-istanbul', name: 'استانبول', provinceId: 'mock-province-istanbul'),
];
