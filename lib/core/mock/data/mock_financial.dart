import '../../../features/financial/data/models/package_models.dart';

/// Returns the seeded package catalog.
List<PackageModel> mockSeedPackages() => const [
  PackageModel(
    id: 'mock-pkg-1',
    title: 'پکیج پایه آزمایش خون',
    description: 'دسترسی به یک آزمایش کامل خون و تحلیل AI',
    price: 500000, // ۵۰ هزار تومان
    durationDays: 30,
    type: 'BLOOD',
    isActive: true,
  ),
  PackageModel(
    id: 'mock-pkg-2',
    title: 'پکیج پیشرفته',
    description: 'دسترسی نامحدود به همهٔ آزمایش‌ها + تحلیل کامل',
    price: 1500000, // ۱۵۰ هزار تومان
    durationDays: 90,
    type: 'BLOOD',
    isActive: true,
  ),
  PackageModel(
    id: 'mock-pkg-3',
    title: 'پکیج ژنتیک',
    description: 'آزمایش ژنتیک + تباربابی',
    price: 3000000, // ۳۰۰ هزار تومان
    durationDays: 180,
    type: 'GENETIC',
    isActive: true,
  ),
];
