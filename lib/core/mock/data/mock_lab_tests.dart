import '../../../features/lab_test/data/models/lab_test_models.dart';

/// Returns the seeded lab tests for the mock environment.
List<LabTestDetail> mockSeedLabTests() => [_testOne(), _testTwo(), _testThree()];

LabTestDetailFile _file({required String id, required String name}) =>
    LabTestDetailFile(id: id, originalName: name, url: 'https://mock.local/files/$id.pdf');

LabTestDetailParameter _p({
  required String id,
  required String catId,
  required String name,
  required String value,
  String? unit,
  String? refMin,
  String? refMax,
  String? flag,
  int sortOrder = 0,
}) => LabTestDetailParameter(
  id: id,
  categoryId: catId,
  name: name,
  value: value,
  unit: unit,
  refMin: refMin,
  refMax: refMax,
  flag: flag,
  sortOrder: sortOrder,
);

LabTestDetail _testOne() {
  const catCbc = 'mock-cat-001-cbc';
  const catLipid = 'mock-cat-001-lipid';

  return LabTestDetail(
    id: 'mock-test-001',
    testDate: '2026-09-15',
    doctorName: 'دکتر احمدی',
    labName: 'آزمایشگاه مرکزی',
    labAddress: 'تهران، خیابان ولیعصر',
    testNumber: '12345',
    createdAt: '2026-09-15T10:30:00.000Z',
    files: [_file(id: 'mock-file-001', name: 'cbc-lipid-1405-06-24.pdf')],
    categories: [
      LabTestDetailCategory(
        id: catCbc,
        name: 'CBC',
        sortOrder: 0,
        parameters: [
          _p(
            id: 'p-001-wbc',
            catId: catCbc,
            name: 'WBC',
            value: '7.2',
            unit: '×10³/µL',
            refMin: '4',
            refMax: '11',
            sortOrder: 0,
          ),
          _p(
            id: 'p-001-rbc',
            catId: catCbc,
            name: 'RBC',
            value: '4.8',
            unit: '×10⁶/µL',
            refMin: '4.5',
            refMax: '5.9',
            sortOrder: 1,
          ),
          _p(
            id: 'p-001-hgb',
            catId: catCbc,
            name: 'HGB',
            value: '13.5',
            unit: 'g/dL',
            refMin: '13',
            refMax: '17',
            sortOrder: 2,
          ),
          _p(
            id: 'p-001-hct',
            catId: catCbc,
            name: 'HCT',
            value: '42',
            unit: '%',
            refMin: '40',
            refMax: '52',
            sortOrder: 3,
          ),
          _p(
            id: 'p-001-plt',
            catId: catCbc,
            name: 'PLT',
            value: '250',
            unit: '×10³/µL',
            refMin: '150',
            refMax: '400',
            sortOrder: 4,
          ),
        ],
      ),
      LabTestDetailCategory(
        id: catLipid,
        name: 'Lipids',
        sortOrder: 1,
        parameters: [
          _p(
            id: 'p-001-chol',
            catId: catLipid,
            name: 'Total Cholesterol',
            value: '190',
            unit: 'mg/dL',
            refMin: '0',
            refMax: '200',
            sortOrder: 0,
          ),
          _p(
            id: 'p-001-hdl',
            catId: catLipid,
            name: 'HDL',
            value: '45',
            unit: 'mg/dL',
            refMin: '40',
            refMax: '80',
            sortOrder: 1,
          ),
          _p(
            id: 'p-001-ldl',
            catId: catLipid,
            name: 'LDL',
            value: '120',
            unit: 'mg/dL',
            refMin: '0',
            refMax: '130',
            sortOrder: 2,
          ),
          _p(
            id: 'p-001-tg',
            catId: catLipid,
            name: 'Triglycerides',
            value: '150',
            unit: 'mg/dL',
            refMin: '0',
            refMax: '150',
            sortOrder: 3,
          ),
        ],
      ),
    ],
  );
}

LabTestDetail _testTwo() {
  const catCbc = 'mock-cat-002-cbc';

  return LabTestDetail(
    id: 'mock-test-002',
    testDate: '2026-10-10',
    doctorName: 'دکتر رضایی',
    labName: 'آزمایشگاه نور',
    labAddress: 'تهران، سعادت‌آباد',
    testNumber: '67890',
    createdAt: '2026-10-10T09:00:00.000Z',
    files: [_file(id: 'mock-file-002', name: 'cbc-1405-07-19.pdf')],
    categories: [
      LabTestDetailCategory(
        id: catCbc,
        name: 'CBC',
        sortOrder: 0,
        parameters: [
          _p(
            id: 'p-002-wbc',
            catId: catCbc,
            name: 'WBC',
            value: '8.5',
            unit: '×10³/µL',
            refMin: '4',
            refMax: '11',
            flag: 'H',
            sortOrder: 0,
          ),
          _p(
            id: 'p-002-rbc',
            catId: catCbc,
            name: 'RBC',
            value: '4.7',
            unit: '×10⁶/µL',
            refMin: '4.5',
            refMax: '5.9',
            sortOrder: 1,
          ),
          _p(
            id: 'p-002-hgb',
            catId: catCbc,
            name: 'HGB',
            value: '13.8',
            unit: 'g/dL',
            refMin: '13',
            refMax: '17',
            sortOrder: 2,
          ),
          _p(
            id: 'p-002-plt',
            catId: catCbc,
            name: 'PLT',
            value: '260',
            unit: '×10³/µL',
            refMin: '150',
            refMax: '400',
            sortOrder: 3,
          ),
        ],
      ),
    ],
  );
}

LabTestDetail _testThree() {
  const catBio = 'mock-cat-003-bio';

  return LabTestDetail(
    id: 'mock-test-003',
    testDate: '2026-10-25',
    doctorName: 'دکتر کریمی',
    labName: 'آزمایشگاه پارس',
    labAddress: 'تهران، ونک',
    testNumber: '11111',
    createdAt: '2026-10-25T08:15:00.000Z',
    files: [_file(id: 'mock-file-003', name: 'bio-1405-08-03.pdf')],
    categories: [
      LabTestDetailCategory(
        id: catBio,
        name: 'Biochemistry',
        sortOrder: 0,
        parameters: [
          _p(
            id: 'p-003-fbs',
            catId: catBio,
            name: 'FBS',
            value: '105',
            unit: 'mg/dL',
            refMin: '70',
            refMax: '100',
            flag: 'H',
            sortOrder: 0,
          ),
          _p(
            id: 'p-003-cr',
            catId: catBio,
            name: 'Creatinine',
            value: '1.1',
            unit: 'mg/dL',
            refMin: '0.7',
            refMax: '1.3',
            sortOrder: 1,
          ),
          _p(
            id: 'p-003-bun',
            catId: catBio,
            name: 'BUN',
            value: '15',
            unit: 'mg/dL',
            refMin: '7',
            refMax: '20',
            sortOrder: 2,
          ),
          _p(
            id: 'p-003-ua',
            catId: catBio,
            name: 'Uric Acid',
            value: '5.5',
            unit: 'mg/dL',
            refMin: '3.5',
            refMax: '7.2',
            sortOrder: 3,
          ),
        ],
      ),
    ],
  );
}
