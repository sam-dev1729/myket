import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fa')];

  /// No description provided for @appName.
  ///
  /// In fa, this message translates to:
  /// **'مدیک متاورس'**
  String get appName;

  /// No description provided for @welcomeBack.
  ///
  /// In fa, this message translates to:
  /// **'خوش آمدید!'**
  String get welcomeBack;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In fa, this message translates to:
  /// **'لطفا شماره موبایل خود را وارد کنید'**
  String get enterPhoneNumber;

  /// No description provided for @phoneNumber.
  ///
  /// In fa, this message translates to:
  /// **'شماره موبایل'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In fa, this message translates to:
  /// **'09123456789'**
  String get phoneHint;

  /// No description provided for @countryCodeIran.
  ///
  /// In fa, this message translates to:
  /// **'+98'**
  String get countryCodeIran;

  /// No description provided for @loginOrSignupButton.
  ///
  /// In fa, this message translates to:
  /// **'ورود / ثبت‌نام'**
  String get loginOrSignupButton;

  /// No description provided for @termsAcceptanceText.
  ///
  /// In fa, this message translates to:
  /// **'ورود یا ثبت‌نام به معنای پذیرش قوانین است'**
  String get termsAcceptanceText;

  /// No description provided for @sendOtp.
  ///
  /// In fa, this message translates to:
  /// **'ارسال کد تایید'**
  String get sendOtp;

  /// No description provided for @continueWithGoogle.
  ///
  /// In fa, this message translates to:
  /// **'ورود با حساب کاربری گوگل'**
  String get continueWithGoogle;

  /// No description provided for @or.
  ///
  /// In fa, this message translates to:
  /// **'یا'**
  String get or;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In fa, this message translates to:
  /// **'لطفا شماره موبایل خود را وارد کنید'**
  String get pleaseEnterPhone;

  /// No description provided for @otpTitle.
  ///
  /// In fa, this message translates to:
  /// **'کد تایید'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'کد ۵ رقمی ارسال شده به {phone} را وارد کنید'**
  String otpSubtitle(String phone);

  /// No description provided for @verifyButton.
  ///
  /// In fa, this message translates to:
  /// **'تایید'**
  String get verifyButton;

  /// No description provided for @resendCode.
  ///
  /// In fa, this message translates to:
  /// **'ارسال مجدد کد'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In fa, this message translates to:
  /// **'ارسال مجدد تا {seconds} ثانیه'**
  String resendIn(String seconds);

  /// No description provided for @otpStillValid.
  ///
  /// In fa, this message translates to:
  /// **'کد تایید قبلی هنوز معتبر است. لطفا از همان کد استفاده کنید.'**
  String get otpStillValid;

  /// No description provided for @otpSentAgain.
  ///
  /// In fa, this message translates to:
  /// **'کد تایید جدید برای شما ارسال شد'**
  String get otpSentAgain;

  /// No description provided for @verificationSuccess.
  ///
  /// In fa, this message translates to:
  /// **'کد تایید با موفقیت ثبت شد'**
  String get verificationSuccess;

  /// No description provided for @invalidOtpError.
  ///
  /// In fa, this message translates to:
  /// **'کد تایید نامعتبر است'**
  String get invalidOtpError;

  /// No description provided for @networkError.
  ///
  /// In fa, this message translates to:
  /// **'خطا در برقراری ارتباط با سرور'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In fa, this message translates to:
  /// **'زمان ارتباط با سرور به پایان رسید. لطفا اتصال اینترنت یا VPN خود را بررسی کنید.'**
  String get timeoutError;

  /// No description provided for @noInternetError.
  ///
  /// In fa, this message translates to:
  /// **'اتصال اینترنت خود را بررسی کنید.'**
  String get noInternetError;

  /// No description provided for @serverError.
  ///
  /// In fa, this message translates to:
  /// **'خطایی در سرور رخ داده است. لطفا بعدا تلاش کنید.'**
  String get serverError;

  /// No description provided for @signUpTitle.
  ///
  /// In fa, this message translates to:
  /// **'تکمیل ثبت‌نام'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'شماره {phone} در سیستم ثبت نشده است. لطفاً نام خود را وارد کنید.'**
  String signUpSubtitle(String phone);

  /// No description provided for @firstName.
  ///
  /// In fa, this message translates to:
  /// **'نام'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In fa, this message translates to:
  /// **'نام خانوادگی'**
  String get lastName;

  /// No description provided for @registerAndLogin.
  ///
  /// In fa, this message translates to:
  /// **'ثبت و ورود'**
  String get registerAndLogin;

  /// No description provided for @pleaseEnterName.
  ///
  /// In fa, this message translates to:
  /// **'لطفا نام و نام خانوادگی خود را وارد کنید'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterDetails.
  ///
  /// In fa, this message translates to:
  /// **'لطفا اطلاعات خود را وارد کنید'**
  String get pleaseEnterDetails;

  /// No description provided for @phoneMissingError.
  ///
  /// In fa, this message translates to:
  /// **'شماره موبایل موجود نیست. لطفا دوباره تلاش کنید.'**
  String get phoneMissingError;

  /// No description provided for @birthDate.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ تولد'**
  String get birthDate;

  /// No description provided for @selectBirthDate.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ تولد خود را انتخاب کنید'**
  String get selectBirthDate;

  /// No description provided for @gender.
  ///
  /// In fa, this message translates to:
  /// **'جنسیت'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In fa, this message translates to:
  /// **'مرد'**
  String get male;

  /// No description provided for @female.
  ///
  /// In fa, this message translates to:
  /// **'زن'**
  String get female;

  /// No description provided for @homeTab.
  ///
  /// In fa, this message translates to:
  /// **'خانه'**
  String get homeTab;

  /// No description provided for @bloodTab.
  ///
  /// In fa, this message translates to:
  /// **'آزمایش خون'**
  String get bloodTab;

  /// No description provided for @geneticTab.
  ///
  /// In fa, this message translates to:
  /// **'ژنتیک'**
  String get geneticTab;

  /// No description provided for @walletTab.
  ///
  /// In fa, this message translates to:
  /// **'کیف پول'**
  String get walletTab;

  /// No description provided for @profileTab.
  ///
  /// In fa, this message translates to:
  /// **'پروفایل'**
  String get profileTab;

  /// No description provided for @featuresTab.
  ///
  /// In fa, this message translates to:
  /// **'امکانات'**
  String get featuresTab;

  /// No description provided for @healthRecordTab.
  ///
  /// In fa, this message translates to:
  /// **'کارنامه سلامت'**
  String get healthRecordTab;

  /// No description provided for @welcomeHome.
  ///
  /// In fa, this message translates to:
  /// **'به مدیک متاورس خوش آمدید'**
  String get welcomeHome;

  /// No description provided for @bloodTestTitle.
  ///
  /// In fa, this message translates to:
  /// **'آزمایش خون'**
  String get bloodTestTitle;

  /// No description provided for @geneticTestTitle.
  ///
  /// In fa, this message translates to:
  /// **'آزمایش ژنتیک'**
  String get geneticTestTitle;

  /// No description provided for @bloodAndUrineTest.
  ///
  /// In fa, this message translates to:
  /// **'آزمایش خون و ادرار'**
  String get bloodAndUrineTest;

  /// No description provided for @geneticTest.
  ///
  /// In fa, this message translates to:
  /// **'آزمایش ژنتیک'**
  String get geneticTest;

  /// No description provided for @geneticGenealogy.
  ///
  /// In fa, this message translates to:
  /// **'تباربابی ژنتیکی'**
  String get geneticGenealogy;

  /// No description provided for @drugInteraction.
  ///
  /// In fa, this message translates to:
  /// **'تداخل دارویی'**
  String get drugInteraction;

  /// No description provided for @aiDoctor.
  ///
  /// In fa, this message translates to:
  /// **'دکتر AI'**
  String get aiDoctor;

  /// No description provided for @noActivePackage.
  ///
  /// In fa, this message translates to:
  /// **'بستهٔ فعال ندارید'**
  String get noActivePackage;

  /// No description provided for @activePackage.
  ///
  /// In fa, this message translates to:
  /// **'بسته فعال است'**
  String get activePackage;

  /// No description provided for @comingSoon.
  ///
  /// In fa, this message translates to:
  /// **'به‌زودی'**
  String get comingSoon;

  /// No description provided for @seeAllFeatures.
  ///
  /// In fa, this message translates to:
  /// **'مشاهده همه امکانات'**
  String get seeAllFeatures;

  /// No description provided for @blog.
  ///
  /// In fa, this message translates to:
  /// **'وبلاگ'**
  String get blog;

  /// No description provided for @blogTitle.
  ///
  /// In fa, this message translates to:
  /// **'مقالات سلامت'**
  String get blogTitle;

  /// No description provided for @aiChatTitle.
  ///
  /// In fa, this message translates to:
  /// **'چت هوش مصنوعی'**
  String get aiChatTitle;

  /// No description provided for @medicalRecordTitle.
  ///
  /// In fa, this message translates to:
  /// **'پرونده پزشکی'**
  String get medicalRecordTitle;

  /// No description provided for @bookAppointmentTitle.
  ///
  /// In fa, this message translates to:
  /// **'نوبت‌دهی'**
  String get bookAppointmentTitle;

  /// No description provided for @seeAllPosts.
  ///
  /// In fa, this message translates to:
  /// **'مشاهده همه مطالب'**
  String get seeAllPosts;

  /// No description provided for @reviewAndAnalyzeTest.
  ///
  /// In fa, this message translates to:
  /// **'بررسی و تحلیل آزمایش'**
  String get reviewAndAnalyzeTest;

  /// No description provided for @searchInContent.
  ///
  /// In fa, this message translates to:
  /// **'جستجو در مطالب'**
  String get searchInContent;

  /// No description provided for @overallHealth.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت کلی سلامت'**
  String get overallHealth;

  /// No description provided for @bloodParameters.
  ///
  /// In fa, this message translates to:
  /// **'پارامترهای خون'**
  String get bloodParameters;

  /// No description provided for @healthyStatus.
  ///
  /// In fa, this message translates to:
  /// **'سالم'**
  String get healthyStatus;

  /// No description provided for @doctorSuggestions.
  ///
  /// In fa, this message translates to:
  /// **'توصیه‌های دستیار پزشک'**
  String get doctorSuggestions;

  /// No description provided for @seeAllSuggestions.
  ///
  /// In fa, this message translates to:
  /// **'مشاهده همه توصیه‌ها'**
  String get seeAllSuggestions;

  /// No description provided for @readMore.
  ///
  /// In fa, this message translates to:
  /// **'بیشتر بخوانید'**
  String get readMore;

  /// No description provided for @doctorSuggestionsDescription.
  ///
  /// In fa, this message translates to:
  /// **'بر اساس وضعیت کلی سلامت بهتر است موارد زیر را رعایت کنید و در صورت لزوم به پزشک مراجعه کنید.'**
  String get doctorSuggestionsDescription;

  /// No description provided for @healthAdvice1.
  ///
  /// In fa, this message translates to:
  /// **'از آزمایش خون چه می‌دانیم؟'**
  String get healthAdvice1;

  /// No description provided for @healthAdvice2.
  ///
  /// In fa, this message translates to:
  /// **'فرق کلسترول خوب و کلسترول بد چیست؟'**
  String get healthAdvice2;

  /// No description provided for @healthAdvice3.
  ///
  /// In fa, this message translates to:
  /// **'آیا برای آزمایش ادرار باید ناشتا باشیم؟'**
  String get healthAdvice3;

  /// No description provided for @gaugeStatusHealthy.
  ///
  /// In fa, this message translates to:
  /// **'سالم'**
  String get gaugeStatusHealthy;

  /// No description provided for @gaugeStatusWarning.
  ///
  /// In fa, this message translates to:
  /// **'نیاز به توجه'**
  String get gaugeStatusWarning;

  /// No description provided for @gaugeStatusDanger.
  ///
  /// In fa, this message translates to:
  /// **'هشدار'**
  String get gaugeStatusDanger;

  /// No description provided for @profileTitle.
  ///
  /// In fa, this message translates to:
  /// **'پروفایل'**
  String get profileTitle;

  /// No description provided for @accountStatus.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت اکانت'**
  String get accountStatus;

  /// No description provided for @userLevelBronze.
  ///
  /// In fa, this message translates to:
  /// **'سطح کاربری: برنزی'**
  String get userLevelBronze;

  /// No description provided for @activePackages.
  ///
  /// In fa, this message translates to:
  /// **'بسته‌های فعال:'**
  String get activePackages;

  /// No description provided for @packageHistory.
  ///
  /// In fa, this message translates to:
  /// **'تاریخچه خرید بسته‌ها'**
  String get packageHistory;

  /// No description provided for @buyPackageTitle.
  ///
  /// In fa, this message translates to:
  /// **'خرید بسته'**
  String get buyPackageTitle;

  /// No description provided for @walletTitle.
  ///
  /// In fa, this message translates to:
  /// **'کیف پول'**
  String get walletTitle;

  /// No description provided for @creditAmountLabel.
  ///
  /// In fa, this message translates to:
  /// **'میزان اعتبار: {amount} {currency}'**
  String creditAmountLabel(String amount, String currency);

  /// No description provided for @transactionHistory.
  ///
  /// In fa, this message translates to:
  /// **'تاریخچه تراکنش‌ها'**
  String get transactionHistory;

  /// No description provided for @cardAndAccountInfo.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات کارت و حساب'**
  String get cardAndAccountInfo;

  /// No description provided for @aboutUs.
  ///
  /// In fa, this message translates to:
  /// **'درباره ما'**
  String get aboutUs;

  /// No description provided for @termsAndConditions.
  ///
  /// In fa, this message translates to:
  /// **'قوانین و شرایط استفاده'**
  String get termsAndConditions;

  /// No description provided for @referToOthers.
  ///
  /// In fa, this message translates to:
  /// **'معرفی به دیگران'**
  String get referToOthers;

  /// No description provided for @versionLabel.
  ///
  /// In fa, this message translates to:
  /// **'نسخه {version}'**
  String versionLabel(String version);

  /// No description provided for @appUpToDate.
  ///
  /// In fa, this message translates to:
  /// **'برنامه شما به‌روز است'**
  String get appUpToDate;

  /// No description provided for @logoutLabel.
  ///
  /// In fa, this message translates to:
  /// **'خروج'**
  String get logoutLabel;

  /// No description provided for @logoutButton.
  ///
  /// In fa, this message translates to:
  /// **'خروج از حساب'**
  String get logoutButton;

  /// No description provided for @deleteAccountButton.
  ///
  /// In fa, this message translates to:
  /// **'حذف حساب کاربری'**
  String get deleteAccountButton;

  /// No description provided for @currencyRial.
  ///
  /// In fa, this message translates to:
  /// **'ریال'**
  String get currencyRial;

  /// No description provided for @currencyToman.
  ///
  /// In fa, this message translates to:
  /// **'تومان'**
  String get currencyToman;

  /// No description provided for @editProfileTitle.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش پروفایل'**
  String get editProfileTitle;

  /// No description provided for @mobileLabel.
  ///
  /// In fa, this message translates to:
  /// **'شماره موبایل'**
  String get mobileLabel;

  /// No description provided for @bloodTypeLabel.
  ///
  /// In fa, this message translates to:
  /// **'گروه خونی'**
  String get bloodTypeLabel;

  /// No description provided for @birthDateLabel.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ تولد'**
  String get birthDateLabel;

  /// No description provided for @heightLabel.
  ///
  /// In fa, this message translates to:
  /// **'قد (سانتی‌متر)'**
  String get heightLabel;

  /// No description provided for @weightLabel.
  ///
  /// In fa, this message translates to:
  /// **'وزن (کیلوگرم)'**
  String get weightLabel;

  /// No description provided for @genderLabel.
  ///
  /// In fa, this message translates to:
  /// **'جنسیت'**
  String get genderLabel;

  /// No description provided for @cancel.
  ///
  /// In fa, this message translates to:
  /// **'انصراف'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In fa, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In fa, this message translates to:
  /// **'تلاش مجدد'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In fa, this message translates to:
  /// **'ثبت نشده'**
  String get noData;

  /// No description provided for @personalInfo.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات شخصی'**
  String get personalInfo;

  /// No description provided for @medicalInfo.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات پزشکی'**
  String get medicalInfo;

  /// No description provided for @allergiesLabel.
  ///
  /// In fa, this message translates to:
  /// **'آلرژی‌ها'**
  String get allergiesLabel;

  /// No description provided for @underlyingDiseasesLabel.
  ///
  /// In fa, this message translates to:
  /// **'بیماری‌های زمینه‌ای'**
  String get underlyingDiseasesLabel;

  /// No description provided for @medicalHistoryLabel.
  ///
  /// In fa, this message translates to:
  /// **'سابقه پزشکی'**
  String get medicalHistoryLabel;

  /// No description provided for @noAllergies.
  ///
  /// In fa, this message translates to:
  /// **'آلرژی ثبت نشده'**
  String get noAllergies;

  /// No description provided for @noDiseases.
  ///
  /// In fa, this message translates to:
  /// **'بیماری ثبت نشده'**
  String get noDiseases;

  /// No description provided for @noMedicalHistory.
  ///
  /// In fa, this message translates to:
  /// **'سابقه‌ای ثبت نشده'**
  String get noMedicalHistory;

  /// No description provided for @accountActions.
  ///
  /// In fa, this message translates to:
  /// **'مدیریت حساب'**
  String get accountActions;

  /// No description provided for @editButton.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش'**
  String get editButton;

  /// No description provided for @saving.
  ///
  /// In fa, this message translates to:
  /// **'در حال ذخیره...'**
  String get saving;

  /// No description provided for @profileUpdated.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات پروفایل با موفقیت به‌روزرسانی شد'**
  String get profileUpdated;

  /// No description provided for @updateError.
  ///
  /// In fa, this message translates to:
  /// **'خطا در به‌روزرسانی اطلاعات'**
  String get updateError;

  /// No description provided for @fullName.
  ///
  /// In fa, this message translates to:
  /// **'نام و نام خانوادگی'**
  String get fullName;

  /// No description provided for @kg.
  ///
  /// In fa, this message translates to:
  /// **'کیلوگرم'**
  String get kg;

  /// No description provided for @cm.
  ///
  /// In fa, this message translates to:
  /// **'سانتی‌متر'**
  String get cm;

  /// No description provided for @editProfileBasicInfo.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات پایه'**
  String get editProfileBasicInfo;

  /// No description provided for @editProfileMedicalInfo.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات پزشکی'**
  String get editProfileMedicalInfo;

  /// No description provided for @selectBloodType.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب گروه خونی'**
  String get selectBloodType;

  /// No description provided for @selectAllergies.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب آلرژی‌ها'**
  String get selectAllergies;

  /// No description provided for @selectDiseases.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب بیماری‌های زمینه‌ای'**
  String get selectDiseases;

  /// No description provided for @selectHistories.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب سوابق پزشکی'**
  String get selectHistories;

  /// No description provided for @searchHint.
  ///
  /// In fa, this message translates to:
  /// **'جستجو...'**
  String get searchHint;

  /// No description provided for @saveChanges.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره تغییرات'**
  String get saveChanges;

  /// No description provided for @profileSavedSuccess.
  ///
  /// In fa, this message translates to:
  /// **'پروفایل با موفقیت ذخیره شد'**
  String get profileSavedSuccess;

  /// No description provided for @noItemsFound.
  ///
  /// In fa, this message translates to:
  /// **'موردی یافت نشد'**
  String get noItemsFound;

  /// No description provided for @errorFetchingProfile.
  ///
  /// In fa, this message translates to:
  /// **'خطا در دریافت اطلاعات پروفایل'**
  String get errorFetchingProfile;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In fa, this message translates to:
  /// **'حذف حساب'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In fa, this message translates to:
  /// **'آیا از حذف حساب کاربری خود اطمینان دارید؟ این عمل غیرقابل بازگشت است.'**
  String get confirmDeleteMessage;

  /// No description provided for @bloodTypeAPositive.
  ///
  /// In fa, this message translates to:
  /// **'A+'**
  String get bloodTypeAPositive;

  /// No description provided for @bloodTypeANegative.
  ///
  /// In fa, this message translates to:
  /// **'A-'**
  String get bloodTypeANegative;

  /// No description provided for @bloodTypeBPositive.
  ///
  /// In fa, this message translates to:
  /// **'B+'**
  String get bloodTypeBPositive;

  /// No description provided for @bloodTypeBNegative.
  ///
  /// In fa, this message translates to:
  /// **'B-'**
  String get bloodTypeBNegative;

  /// No description provided for @bloodTypeABPositive.
  ///
  /// In fa, this message translates to:
  /// **'AB+'**
  String get bloodTypeABPositive;

  /// No description provided for @bloodTypeABNegative.
  ///
  /// In fa, this message translates to:
  /// **'AB-'**
  String get bloodTypeABNegative;

  /// No description provided for @bloodTypeOPositive.
  ///
  /// In fa, this message translates to:
  /// **'O+'**
  String get bloodTypeOPositive;

  /// No description provided for @bloodTypeONegative.
  ///
  /// In fa, this message translates to:
  /// **'O-'**
  String get bloodTypeONegative;

  /// No description provided for @linkedAccounts.
  ///
  /// In fa, this message translates to:
  /// **'حساب‌های متصل'**
  String get linkedAccounts;

  /// No description provided for @emailLabel.
  ///
  /// In fa, this message translates to:
  /// **'ایمیل'**
  String get emailLabel;

  /// No description provided for @notConnected.
  ///
  /// In fa, this message translates to:
  /// **'متصل نشده'**
  String get notConnected;

  /// No description provided for @attachGoogle.
  ///
  /// In fa, this message translates to:
  /// **'اتصال حساب گوگل'**
  String get attachGoogle;

  /// No description provided for @detachGoogle.
  ///
  /// In fa, this message translates to:
  /// **'قطع اتصال گوگل'**
  String get detachGoogle;

  /// No description provided for @googleAccountLinkedSuccess.
  ///
  /// In fa, this message translates to:
  /// **'حساب گوگل با موفقیت متصل شد'**
  String get googleAccountLinkedSuccess;

  /// No description provided for @googleAccountDetachedSuccess.
  ///
  /// In fa, this message translates to:
  /// **'اتصال حساب گوگل قطع شد'**
  String get googleAccountDetachedSuccess;

  /// No description provided for @uploadLabTest.
  ///
  /// In fa, this message translates to:
  /// **'آپلود آزمایش'**
  String get uploadLabTest;

  /// No description provided for @selectFile.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب فایل آزمایش (PDF)'**
  String get selectFile;

  /// No description provided for @uploadingFile.
  ///
  /// In fa, this message translates to:
  /// **'در حال آپلود فایل...'**
  String get uploadingFile;

  /// No description provided for @extractingData.
  ///
  /// In fa, this message translates to:
  /// **'در حال تحلیل با هوش مصنوعی...'**
  String get extractingData;

  /// No description provided for @extractionSuccess.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات آزمایش با موفقیت استخراج شد'**
  String get extractionSuccess;

  /// No description provided for @uploadFailed.
  ///
  /// In fa, this message translates to:
  /// **'خطا در آپلود فایل'**
  String get uploadFailed;

  /// No description provided for @extractionFailed.
  ///
  /// In fa, this message translates to:
  /// **'خطا در استخراج اطلاعات'**
  String get extractionFailed;

  /// No description provided for @fileSelected.
  ///
  /// In fa, this message translates to:
  /// **'فایل انتخاب شده'**
  String get fileSelected;

  /// No description provided for @previewExtractedData.
  ///
  /// In fa, this message translates to:
  /// **'پیش‌نمایش اطلاعات استخراج شده'**
  String get previewExtractedData;

  /// No description provided for @testDate.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ آزمایش'**
  String get testDate;

  /// No description provided for @doctorName.
  ///
  /// In fa, this message translates to:
  /// **'نام پزشک'**
  String get doctorName;

  /// No description provided for @labName.
  ///
  /// In fa, this message translates to:
  /// **'نام آزمایشگاه'**
  String get labName;

  /// No description provided for @categories.
  ///
  /// In fa, this message translates to:
  /// **'دسته‌بندی‌ها'**
  String get categories;

  /// No description provided for @parameters.
  ///
  /// In fa, this message translates to:
  /// **'پارامترها'**
  String get parameters;

  /// No description provided for @savingLabTest.
  ///
  /// In fa, this message translates to:
  /// **'در حال ذخیره آزمایش...'**
  String get savingLabTest;

  /// No description provided for @labTestSavedSuccess.
  ///
  /// In fa, this message translates to:
  /// **'آزمایش با موفقیت ذخیره شد'**
  String get labTestSavedSuccess;

  /// No description provided for @labTestSaveFailed.
  ///
  /// In fa, this message translates to:
  /// **'خطا در ذخیره آزمایش'**
  String get labTestSaveFailed;

  /// No description provided for @saveLabTest.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره آزمایش'**
  String get saveLabTest;

  /// No description provided for @noLabTestsFound.
  ///
  /// In fa, this message translates to:
  /// **'هیچ آزمایشی ثبت نشده است'**
  String get noLabTestsFound;

  /// No description provided for @addNewLabTest.
  ///
  /// In fa, this message translates to:
  /// **'ثبت آزمایش جدید'**
  String get addNewLabTest;

  /// No description provided for @labTestListTitle.
  ///
  /// In fa, this message translates to:
  /// **'آزمایش خون'**
  String get labTestListTitle;

  /// No description provided for @labTestCardTitle.
  ///
  /// In fa, this message translates to:
  /// **'آزمایش خون {number}'**
  String labTestCardTitle(String number);

  /// No description provided for @centralHospital.
  ///
  /// In fa, this message translates to:
  /// **'Central Hospital'**
  String get centralHospital;

  /// No description provided for @walletTabTitle.
  ///
  /// In fa, this message translates to:
  /// **'کیف پول'**
  String get walletTabTitle;

  /// No description provided for @walletBalanceLabel.
  ///
  /// In fa, this message translates to:
  /// **'موجودی قابل استفاده'**
  String get walletBalanceLabel;

  /// No description provided for @walletTopupButton.
  ///
  /// In fa, this message translates to:
  /// **'شارژ'**
  String get walletTopupButton;

  /// No description provided for @walletBuyPackageButton.
  ///
  /// In fa, this message translates to:
  /// **'خرید پکیج'**
  String get walletBuyPackageButton;

  /// No description provided for @walletRecentTransactionsTitle.
  ///
  /// In fa, this message translates to:
  /// **'تراکنش‌های اخیر'**
  String get walletRecentTransactionsTitle;

  /// No description provided for @walletSeeAllButton.
  ///
  /// In fa, this message translates to:
  /// **'همه'**
  String get walletSeeAllButton;

  /// No description provided for @walletNoTransactions.
  ///
  /// In fa, this message translates to:
  /// **'هنوز تراکنشی ندارید'**
  String get walletNoTransactions;

  /// No description provided for @increaseCreditTitle.
  ///
  /// In fa, this message translates to:
  /// **'افزایش اعتبار کیف پول'**
  String get increaseCreditTitle;

  /// No description provided for @currentBalance.
  ///
  /// In fa, this message translates to:
  /// **'موجودی فعلی'**
  String get currentBalance;

  /// No description provided for @selectAmount.
  ///
  /// In fa, this message translates to:
  /// **'مبلغ افزایش را انتخاب کنید'**
  String get selectAmount;

  /// No description provided for @customAmount.
  ///
  /// In fa, this message translates to:
  /// **'مبلغ دلخواه'**
  String get customAmount;

  /// No description provided for @payAmount.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت {amount} ریال'**
  String payAmount(String amount);

  /// No description provided for @payButton.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت'**
  String get payButton;

  /// No description provided for @topupScreenTitle.
  ///
  /// In fa, this message translates to:
  /// **'شارژ کیف پول'**
  String get topupScreenTitle;

  /// No description provided for @topupAmountLabel.
  ///
  /// In fa, this message translates to:
  /// **'مبلغ شارژ (تومان)'**
  String get topupAmountLabel;

  /// No description provided for @topupCustomAmountLabel.
  ///
  /// In fa, this message translates to:
  /// **'مبلغ دلخواه'**
  String get topupCustomAmountLabel;

  /// No description provided for @topupPayButton.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت'**
  String get topupPayButton;

  /// No description provided for @topupAmountRequiredError.
  ///
  /// In fa, this message translates to:
  /// **'مبلغ را وارد کنید'**
  String get topupAmountRequiredError;

  /// No description provided for @topupCannotOpenGatewayError.
  ///
  /// In fa, this message translates to:
  /// **'امکان باز کردن درگاه نیست'**
  String get topupCannotOpenGatewayError;

  /// No description provided for @topupUnknownError.
  ///
  /// In fa, this message translates to:
  /// **'خطای ناشناخته'**
  String get topupUnknownError;

  /// No description provided for @transactionsScreenTitle.
  ///
  /// In fa, this message translates to:
  /// **'تاریخچه تراکنش‌ها'**
  String get transactionsScreenTitle;

  /// No description provided for @transactionsEmpty.
  ///
  /// In fa, this message translates to:
  /// **'تراکنشی وجود ندارد'**
  String get transactionsEmpty;

  /// No description provided for @transactionsErrorPrefix.
  ///
  /// In fa, this message translates to:
  /// **'خطا'**
  String get transactionsErrorPrefix;

  /// No description provided for @transactionReasonWalletTopup.
  ///
  /// In fa, this message translates to:
  /// **'شارژ کیف پول'**
  String get transactionReasonWalletTopup;

  /// No description provided for @transactionReasonPackagePurchase.
  ///
  /// In fa, this message translates to:
  /// **'خرید پکیج'**
  String get transactionReasonPackagePurchase;

  /// No description provided for @packagesScreenTitle.
  ///
  /// In fa, this message translates to:
  /// **'خرید بسته'**
  String get packagesScreenTitle;

  /// No description provided for @packagesEmpty.
  ///
  /// In fa, this message translates to:
  /// **'بسته‌ای موجود نیست'**
  String get packagesEmpty;

  /// No description provided for @packagesErrorTitle.
  ///
  /// In fa, this message translates to:
  /// **'خطا'**
  String get packagesErrorTitle;

  /// No description provided for @packagesRetryButton.
  ///
  /// In fa, this message translates to:
  /// **'تلاش مجدد'**
  String get packagesRetryButton;

  /// No description provided for @packagesBuyButton.
  ///
  /// In fa, this message translates to:
  /// **'خرید'**
  String get packagesBuyButton;

  /// No description provided for @packagesDurationDays.
  ///
  /// In fa, this message translates to:
  /// **'{days} روز'**
  String packagesDurationDays(int days);

  /// No description provided for @selectPackageDescription.
  ///
  /// In fa, this message translates to:
  /// **'بسته‌ها به شما دسترسی مشاهده اطلاعات پیشرفته و تحلیل نتایج را می‌دهند.'**
  String get selectPackageDescription;

  /// No description provided for @buyPackageScreenTitle.
  ///
  /// In fa, this message translates to:
  /// **'خرید بسته'**
  String get buyPackageScreenTitle;

  /// No description provided for @buyPackageDiscountLabel.
  ///
  /// In fa, this message translates to:
  /// **'کد تخفیف (اختیاری)'**
  String get buyPackageDiscountLabel;

  /// No description provided for @buyPackageUseWalletLabel.
  ///
  /// In fa, this message translates to:
  /// **'استفاده از کیف پول'**
  String get buyPackageUseWalletLabel;

  /// No description provided for @buyPackageWalletBalanceLabel.
  ///
  /// In fa, this message translates to:
  /// **'موجودی: {balance}'**
  String buyPackageWalletBalanceLabel(String balance);

  /// No description provided for @buyPackageGatewayHint.
  ///
  /// In fa, this message translates to:
  /// **'در صورت نیاز به پرداخت آنلاین، پس از ثبت سفارش درگاه انتخاب می‌شود.'**
  String get buyPackageGatewayHint;

  /// No description provided for @buyPackageSubmitButton.
  ///
  /// In fa, this message translates to:
  /// **'ثبت و پرداخت'**
  String get buyPackageSubmitButton;

  /// No description provided for @buyPackageSuccessMessage.
  ///
  /// In fa, this message translates to:
  /// **'خرید با موفقیت انجام شد'**
  String get buyPackageSuccessMessage;

  /// No description provided for @buyPackageNoGatewayUrlError.
  ///
  /// In fa, this message translates to:
  /// **'لینک درگاه دریافت نشد'**
  String get buyPackageNoGatewayUrlError;

  /// No description provided for @buyPackagePurchaseError.
  ///
  /// In fa, this message translates to:
  /// **'خطا در خرید'**
  String get buyPackagePurchaseError;

  /// No description provided for @paymentStatusSuccessTitle.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت موفق'**
  String get paymentStatusSuccessTitle;

  /// No description provided for @paymentStatusSuccessMessage.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت شما با موفقیت انجام شد.'**
  String get paymentStatusSuccessMessage;

  /// No description provided for @paymentStatusPendingTitle.
  ///
  /// In fa, this message translates to:
  /// **'در حال پردازش'**
  String get paymentStatusPendingTitle;

  /// No description provided for @paymentStatusPendingMessage.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت شما در حال پردازش است. نتیجه پس از تایید بانک اعمال می‌شود.'**
  String get paymentStatusPendingMessage;

  /// No description provided for @paymentStatusFailedTitle.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت ناموفق'**
  String get paymentStatusFailedTitle;

  /// No description provided for @paymentStatusFailedMessage.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت انجام نشد. در صورت کسر وجه، مبلغ تا ۷۲ ساعت به حساب شما باز می‌گردد.'**
  String get paymentStatusFailedMessage;

  /// No description provided for @paymentStatusBackHomeButton.
  ///
  /// In fa, this message translates to:
  /// **'بازگشت به خانه'**
  String get paymentStatusBackHomeButton;

  /// No description provided for @paymentGatewaySheetTitle.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب درگاه پرداخت'**
  String get paymentGatewaySheetTitle;

  /// No description provided for @paymentGatewayZarinpal.
  ///
  /// In fa, this message translates to:
  /// **'زرین‌پال'**
  String get paymentGatewayZarinpal;

  /// No description provided for @paymentGatewayAp.
  ///
  /// In fa, this message translates to:
  /// **'آسان پرداخت (AP)'**
  String get paymentGatewayAp;

  /// No description provided for @paymentGatewayCancelButton.
  ///
  /// In fa, this message translates to:
  /// **'انصراف'**
  String get paymentGatewayCancelButton;

  /// No description provided for @paymentGatewayDisabledLabel.
  ///
  /// In fa, this message translates to:
  /// **'غیرفعال'**
  String get paymentGatewayDisabledLabel;

  /// No description provided for @paymentGatewayErrorTitle.
  ///
  /// In fa, this message translates to:
  /// **'خطا'**
  String get paymentGatewayErrorTitle;

  /// No description provided for @paymentGatewayRetryButton.
  ///
  /// In fa, this message translates to:
  /// **'تلاش مجدد'**
  String get paymentGatewayRetryButton;

  /// No description provided for @cardInfoTitle.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات کارت و حساب'**
  String get cardInfoTitle;

  /// No description provided for @cardInfoSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'شماره شبای خود را وارد کنید'**
  String get cardInfoSubtitle;

  /// No description provided for @cardInfoSubtitleHint.
  ///
  /// In fa, this message translates to:
  /// **'این شماره باید به نام خود شما باشد.'**
  String get cardInfoSubtitleHint;

  /// No description provided for @cardNumber.
  ///
  /// In fa, this message translates to:
  /// **'شماره کارت'**
  String get cardNumber;

  /// No description provided for @ibanNumber.
  ///
  /// In fa, this message translates to:
  /// **'شماره شبا'**
  String get ibanNumber;

  /// No description provided for @saveAndReturn.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره و بازگشت'**
  String get saveAndReturn;

  /// No description provided for @cardInfoSavedSuccess.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات بانکی با موفقیت ذخیره شد'**
  String get cardInfoSavedSuccess;

  /// No description provided for @supportTitle.
  ///
  /// In fa, this message translates to:
  /// **'پشتیبانی'**
  String get supportTitle;

  /// No description provided for @supportSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'پاسخگوی سوالات شما هستیم'**
  String get supportSubtitle;

  /// No description provided for @supportGreetingTitle.
  ///
  /// In fa, this message translates to:
  /// **'پشتیبانی سایت'**
  String get supportGreetingTitle;

  /// No description provided for @supportInputHint.
  ///
  /// In fa, this message translates to:
  /// **'پیامی بنویسید...'**
  String get supportInputHint;

  /// No description provided for @supportLoadingError.
  ///
  /// In fa, this message translates to:
  /// **'خطا در بارگذاری پشتیبانی'**
  String get supportLoadingError;

  /// No description provided for @notificationsTitle.
  ///
  /// In fa, this message translates to:
  /// **'اعلان‌ها'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In fa, this message translates to:
  /// **'اعلانی وجود ندارد'**
  String get notificationsEmpty;

  /// No description provided for @notificationsErrorPrefix.
  ///
  /// In fa, this message translates to:
  /// **'خطا'**
  String get notificationsErrorPrefix;

  /// No description provided for @notificationsSearchHint.
  ///
  /// In fa, this message translates to:
  /// **'جستجو در مطالب'**
  String get notificationsSearchHint;

  /// No description provided for @notificationPrivacyTag.
  ///
  /// In fa, this message translates to:
  /// **'PRIVATE'**
  String get notificationPrivacyTag;

  /// No description provided for @notificationsDatePrefix.
  ///
  /// In fa, this message translates to:
  /// **'آبان'**
  String get notificationsDatePrefix;

  /// No description provided for @notificationsWelcomeTitle.
  ///
  /// In fa, this message translates to:
  /// **'به مدیک متاورس خوش آمدید! 🎉'**
  String get notificationsWelcomeTitle;

  /// No description provided for @notificationsWelcomeBody.
  ///
  /// In fa, this message translates to:
  /// **'یاسر عزیز، ثبت‌نامت با موفقیت انجام شد. همین حالا اولین آزمایش خونت رو آپلود کن و تحلیل...'**
  String get notificationsWelcomeBody;

  /// No description provided for @notificationsGoogleLinkedTitle.
  ///
  /// In fa, this message translates to:
  /// **'اتصال موفق جیمیل به حساب کاربری'**
  String get notificationsGoogleLinkedTitle;

  /// No description provided for @notificationsGoogleLinkedBody.
  ///
  /// In fa, this message translates to:
  /// **'جیمیل با آدرس sam.dev.1729@gmail.com به حساب ک...'**
  String get notificationsGoogleLinkedBody;

  /// No description provided for @genericRetryButton.
  ///
  /// In fa, this message translates to:
  /// **'تلاش مجدد'**
  String get genericRetryButton;

  /// No description provided for @genericErrorPrefix.
  ///
  /// In fa, this message translates to:
  /// **'خطا'**
  String get genericErrorPrefix;

  /// No description provided for @genericCancelButton.
  ///
  /// In fa, this message translates to:
  /// **'انصراف'**
  String get genericCancelButton;

  /// No description provided for @genericLoading.
  ///
  /// In fa, this message translates to:
  /// **'لطفا صبر کنید...'**
  String get genericLoading;

  /// No description provided for @currencyTomanSuffix.
  ///
  /// In fa, this message translates to:
  /// **'تومان'**
  String get currencyTomanSuffix;

  /// No description provided for @currencyTomanWithAmount.
  ///
  /// In fa, this message translates to:
  /// **'{amount} تومان'**
  String currencyTomanWithAmount(String amount);

  /// No description provided for @loginPhonePlaceholder.
  ///
  /// In fa, this message translates to:
  /// **'۰۹۱۲۳۴۵۶۷۸۹'**
  String get loginPhonePlaceholder;

  /// No description provided for @buyPackageSelectionTitle.
  ///
  /// In fa, this message translates to:
  /// **'بسته مورد نظر را انتخاب کنید'**
  String get buyPackageSelectionTitle;

  /// No description provided for @buyPackageSelectionSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'بسته‌ها به شما دسترسی مشاهده اطلاعات پیشرفته و تحلیل نتایج را می‌دهند.'**
  String get buyPackageSelectionSubtitle;

  /// No description provided for @topupCurrentBalanceLabel.
  ///
  /// In fa, this message translates to:
  /// **'موجودی فعلی'**
  String get topupCurrentBalanceLabel;

  /// No description provided for @topupSelectAmountLabel.
  ///
  /// In fa, this message translates to:
  /// **'مبلغ افزایش را انتخاب کنید'**
  String get topupSelectAmountLabel;

  /// No description provided for @topupPayWithRial.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت ریال'**
  String get topupPayWithRial;

  /// No description provided for @buyPackagePayWithRial.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت {amount} ریال'**
  String buyPackagePayWithRial(String amount);

  /// No description provided for @notificationItemDate.
  ///
  /// In fa, this message translates to:
  /// **'{day} {month} {year}'**
  String notificationItemDate(String day, String month, String year);

  /// No description provided for @moreOptions.
  ///
  /// In fa, this message translates to:
  /// **'گزینه‌های بیشتر'**
  String get moreOptions;

  /// No description provided for @firstNameField.
  ///
  /// In fa, this message translates to:
  /// **'نام'**
  String get firstNameField;

  /// No description provided for @lastNameField.
  ///
  /// In fa, this message translates to:
  /// **'نام خانوادگی'**
  String get lastNameField;

  /// No description provided for @selectCityLabel.
  ///
  /// In fa, this message translates to:
  /// **'شهر'**
  String get selectCityLabel;

  /// No description provided for @noValueSelected.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب نشده'**
  String get noValueSelected;

  /// No description provided for @searchCityHint.
  ///
  /// In fa, this message translates to:
  /// **'جستجوی شهر...'**
  String get searchCityHint;

  /// No description provided for @noCitiesFound.
  ///
  /// In fa, this message translates to:
  /// **'شهری یافت نشد'**
  String get noCitiesFound;

  /// No description provided for @pleaseEnterFirstNameError.
  ///
  /// In fa, this message translates to:
  /// **'لطفا نام را وارد کنید'**
  String get pleaseEnterFirstNameError;

  /// No description provided for @pleaseEnterLastNameError.
  ///
  /// In fa, this message translates to:
  /// **'لطفا نام خانوادگی را وارد کنید'**
  String get pleaseEnterLastNameError;

  /// No description provided for @pleaseSelectBirthDateError.
  ///
  /// In fa, this message translates to:
  /// **'لطفا تاریخ تولد را انتخاب کنید'**
  String get pleaseSelectBirthDateError;

  /// No description provided for @pleaseSelectGenderError.
  ///
  /// In fa, this message translates to:
  /// **'لطفا جنسیت را انتخاب کنید'**
  String get pleaseSelectGenderError;

  /// No description provided for @citySelectionTitle.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب شهر'**
  String get citySelectionTitle;

  /// No description provided for @termsAcceptanceError.
  ///
  /// In fa, this message translates to:
  /// **'برای ادامه باید قوانین را بپذیرید'**
  String get termsAcceptanceError;

  /// No description provided for @backArrowTooltip.
  ///
  /// In fa, this message translates to:
  /// **'بازگشت'**
  String get backArrowTooltip;

  /// No description provided for @mustFillProfileTitle.
  ///
  /// In fa, this message translates to:
  /// **'تکمیل اطلاعات پروفایل'**
  String get mustFillProfileTitle;

  /// No description provided for @mustFillProfileHeading.
  ///
  /// In fa, this message translates to:
  /// **'برای ادامه، اطلاعات پروفایل را کامل کنید'**
  String get mustFillProfileHeading;

  /// No description provided for @mustFillProfileDescription.
  ///
  /// In fa, this message translates to:
  /// **'برای استفاده از این قابلیت، ابتدا اطلاعات ضروری پروفایل خود را تکمیل کنید.'**
  String get mustFillProfileDescription;

  /// No description provided for @mustFillProfileMissingFields.
  ///
  /// In fa, this message translates to:
  /// **'فیلدهای ضروری که باید تکمیل شوند:'**
  String get mustFillProfileMissingFields;

  /// No description provided for @mustFillProfileCta.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش پروفایل'**
  String get mustFillProfileCta;

  /// No description provided for @emptyPackageTitle.
  ///
  /// In fa, this message translates to:
  /// **'بسته فعال'**
  String get emptyPackageTitle;

  /// No description provided for @emptyPackageHeading.
  ///
  /// In fa, this message translates to:
  /// **'بسته فعالی ندارید'**
  String get emptyPackageHeading;

  /// No description provided for @emptyPackageDescription.
  ///
  /// In fa, this message translates to:
  /// **'برای استفاده از این قابلیت، ابتدا یک بسته خریداری کنید.'**
  String get emptyPackageDescription;

  /// No description provided for @emptyPackageCta.
  ///
  /// In fa, this message translates to:
  /// **'مشاهده بسته‌ها'**
  String get emptyPackageCta;

  /// No description provided for @labTestDetailTitle.
  ///
  /// In fa, this message translates to:
  /// **'جزئیات آزمایش'**
  String get labTestDetailTitle;

  /// No description provided for @labTestDetailFiles.
  ///
  /// In fa, this message translates to:
  /// **'فایل‌های پیوست'**
  String get labTestDetailFiles;

  /// No description provided for @labTestDetailLabAddress.
  ///
  /// In fa, this message translates to:
  /// **'آدرس آزمایشگاه'**
  String get labTestDetailLabAddress;

  /// No description provided for @labTestDetailTestNumber.
  ///
  /// In fa, this message translates to:
  /// **'شماره آزمایش'**
  String get labTestDetailTestNumber;

  /// No description provided for @labTestFlagHigh.
  ///
  /// In fa, this message translates to:
  /// **'بالا'**
  String get labTestFlagHigh;

  /// No description provided for @labTestFlagLow.
  ///
  /// In fa, this message translates to:
  /// **'پایین'**
  String get labTestFlagLow;

  /// No description provided for @labTestOpenFile.
  ///
  /// In fa, this message translates to:
  /// **'باز کردن فایل'**
  String get labTestOpenFile;

  /// No description provided for @labTestParameterRange.
  ///
  /// In fa, this message translates to:
  /// **'محدوده: {min} - {max}'**
  String labTestParameterRange(String min, String max);

  /// No description provided for @labTestDeleteConfirmTitle.
  ///
  /// In fa, this message translates to:
  /// **'حذف آزمایش'**
  String get labTestDeleteConfirmTitle;

  /// No description provided for @labTestDeleteConfirmMessage.
  ///
  /// In fa, this message translates to:
  /// **'آیا از حذف این آزمایش اطمینان دارید؟ این عمل غیرقابل بازگشت است.'**
  String get labTestDeleteConfirmMessage;

  /// No description provided for @labTestDeleted.
  ///
  /// In fa, this message translates to:
  /// **'آزمایش با موفقیت حذف شد'**
  String get labTestDeleted;

  /// No description provided for @labTestDeleteFailed.
  ///
  /// In fa, this message translates to:
  /// **'خطا در حذف آزمایش'**
  String get labTestDeleteFailed;

  /// No description provided for @healthOverviewNoData.
  ///
  /// In fa, this message translates to:
  /// **'هنوز داده سلامت ندارید. اولین آزمایش خود را آپلود کنید.'**
  String get healthOverviewNoData;

  /// No description provided for @healthOverviewKeyMarkers.
  ///
  /// In fa, this message translates to:
  /// **'شاخص‌های کلیدی'**
  String get healthOverviewKeyMarkers;

  /// No description provided for @labOverviewTitle.
  ///
  /// In fa, this message translates to:
  /// **'نتایج کامل آزمایش'**
  String get labOverviewTitle;

  /// No description provided for @labOverviewSearchHint.
  ///
  /// In fa, this message translates to:
  /// **'جستجوی پارامتر...'**
  String get labOverviewSearchHint;

  /// No description provided for @labOverviewEmpty.
  ///
  /// In fa, this message translates to:
  /// **'هنوز پارامتری برای نمایش نیست'**
  String get labOverviewEmpty;

  /// No description provided for @labOverviewSeeAllCta.
  ///
  /// In fa, this message translates to:
  /// **'مشاهده نتایج کامل'**
  String get labOverviewSeeAllCta;

  /// No description provided for @labOverviewStatusGreen.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت: سالم'**
  String get labOverviewStatusGreen;

  /// No description provided for @labOverviewStatusOrange.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت: نیاز به توجه'**
  String get labOverviewStatusOrange;

  /// No description provided for @labOverviewStatusRed.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت: هشدار'**
  String get labOverviewStatusRed;

  /// No description provided for @labOverviewNoData.
  ///
  /// In fa, this message translates to:
  /// **'داده‌ای برای نمایش وجود ندارد'**
  String get labOverviewNoData;

  /// No description provided for @analytePickerTitle.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب پارامترها'**
  String get analytePickerTitle;

  /// No description provided for @analytePickerSearchHint.
  ///
  /// In fa, this message translates to:
  /// **'جستجوی پارامتر...'**
  String get analytePickerSearchHint;

  /// No description provided for @analytePickerEmpty.
  ///
  /// In fa, this message translates to:
  /// **'پارامتری یافت نشد'**
  String get analytePickerEmpty;

  /// No description provided for @analytePickerSubmit.
  ///
  /// In fa, this message translates to:
  /// **'تایید'**
  String get analytePickerSubmit;

  /// No description provided for @analyteSeriesTitle.
  ///
  /// In fa, this message translates to:
  /// **'نمودار تغییرات'**
  String get analyteSeriesTitle;

  /// No description provided for @analyteSeriesPickTooltip.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب پارامترها'**
  String get analyteSeriesPickTooltip;

  /// No description provided for @analyteSeriesChangeAnalytes.
  ///
  /// In fa, this message translates to:
  /// **'تغییر پارامترها'**
  String get analyteSeriesChangeAnalytes;

  /// No description provided for @analyteSeriesNoData.
  ///
  /// In fa, this message translates to:
  /// **'داده‌ای برای این پارامترها وجود ندارد'**
  String get analyteSeriesNoData;

  /// No description provided for @analyteSeriesEmptyTitle.
  ///
  /// In fa, this message translates to:
  /// **'پارامتری انتخاب نشده'**
  String get analyteSeriesEmptyTitle;

  /// No description provided for @analyteSeriesEmptyDescription.
  ///
  /// In fa, this message translates to:
  /// **'برای مشاهده نمودار، حداقل یک پارامتر انتخاب کنید'**
  String get analyteSeriesEmptyDescription;

  /// No description provided for @personalInfoFullTitle.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات شخصی'**
  String get personalInfoFullTitle;

  /// No description provided for @editPersonalInfoCta.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش اطلاعات شخصی'**
  String get editPersonalInfoCta;

  /// No description provided for @profileSectionIdentity.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات شناسایی'**
  String get profileSectionIdentity;

  /// No description provided for @profileSectionVitals.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات فیزیکی'**
  String get profileSectionVitals;

  /// No description provided for @profileSectionMedical.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات پزشکی'**
  String get profileSectionMedical;

  /// No description provided for @isPregnantLabel.
  ///
  /// In fa, this message translates to:
  /// **'بارداری'**
  String get isPregnantLabel;

  /// No description provided for @yesLabel.
  ///
  /// In fa, this message translates to:
  /// **'بله'**
  String get yesLabel;

  /// No description provided for @noLabel.
  ///
  /// In fa, this message translates to:
  /// **'خیر'**
  String get noLabel;

  /// No description provided for @viewFullLabel.
  ///
  /// In fa, this message translates to:
  /// **'مشاهده کامل'**
  String get viewFullLabel;

  /// No description provided for @selectCountryTitle.
  ///
  /// In fa, this message translates to:
  /// **'کشور'**
  String get selectCountryTitle;

  /// No description provided for @selectProvinceTitle.
  ///
  /// In fa, this message translates to:
  /// **'استان'**
  String get selectProvinceTitle;

  /// No description provided for @pleaseSelectProvinceError.
  ///
  /// In fa, this message translates to:
  /// **'لطفا ابتدا استان را انتخاب کنید'**
  String get pleaseSelectProvinceError;

  /// No description provided for @iDontHaveAny.
  ///
  /// In fa, this message translates to:
  /// **'هیچ کدام را ندارم'**
  String get iDontHaveAny;

  /// No description provided for @editLabTestTitle.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش آزمایش'**
  String get editLabTestTitle;

  /// No description provided for @addCategoryButton.
  ///
  /// In fa, this message translates to:
  /// **'افزودن دسته'**
  String get addCategoryButton;

  /// No description provided for @editCategoryTitle.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش دسته'**
  String get editCategoryTitle;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In fa, this message translates to:
  /// **'حذف دسته'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryConfirmMessage.
  ///
  /// In fa, this message translates to:
  /// **'آیا از حذف این دسته و همهٔ پارامترهای آن اطمینان دارید؟'**
  String get deleteCategoryConfirmMessage;

  /// No description provided for @addParameterButton.
  ///
  /// In fa, this message translates to:
  /// **'افزودن پارامتر'**
  String get addParameterButton;

  /// No description provided for @editParameterTitle.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش پارامتر'**
  String get editParameterTitle;

  /// No description provided for @deleteParameterTitle.
  ///
  /// In fa, this message translates to:
  /// **'حذف پارامتر'**
  String get deleteParameterTitle;

  /// No description provided for @deleteParameterConfirmMessage.
  ///
  /// In fa, this message translates to:
  /// **'آیا از حذف این پارامتر اطمینان دارید؟'**
  String get deleteParameterConfirmMessage;

  /// No description provided for @editHeaderTitle.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش اطلاعات آزمایش'**
  String get editHeaderTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In fa, this message translates to:
  /// **'نام دسته'**
  String get categoryNameLabel;

  /// No description provided for @parameterNameLabel.
  ///
  /// In fa, this message translates to:
  /// **'نام پارامتر'**
  String get parameterNameLabel;

  /// No description provided for @parameterValueLabel.
  ///
  /// In fa, this message translates to:
  /// **'مقدار'**
  String get parameterValueLabel;

  /// No description provided for @parameterUnitLabel.
  ///
  /// In fa, this message translates to:
  /// **'واحد'**
  String get parameterUnitLabel;

  /// No description provided for @parameterRefMinLabel.
  ///
  /// In fa, this message translates to:
  /// **'حداقل نرمال'**
  String get parameterRefMinLabel;

  /// No description provided for @parameterRefMaxLabel.
  ///
  /// In fa, this message translates to:
  /// **'حداکثر نرمال'**
  String get parameterRefMaxLabel;

  /// No description provided for @parameterFlagLabel.
  ///
  /// In fa, this message translates to:
  /// **'علامت'**
  String get parameterFlagLabel;

  /// No description provided for @parameterCategoryLabel.
  ///
  /// In fa, this message translates to:
  /// **'دسته'**
  String get parameterCategoryLabel;

  /// No description provided for @editLabTestMutationsInFlight.
  ///
  /// In fa, this message translates to:
  /// **'در حال ذخیره...'**
  String get editLabTestMutationsInFlight;

  /// No description provided for @labTestUpdatedSuccess.
  ///
  /// In fa, this message translates to:
  /// **'آزمایش با موفقیت به‌روزرسانی شد'**
  String get labTestUpdatedSuccess;

  /// No description provided for @categoryNameRequiredError.
  ///
  /// In fa, this message translates to:
  /// **'نام دسته نمی‌تواند خالی باشد'**
  String get categoryNameRequiredError;

  /// No description provided for @labTestFlagNone.
  ///
  /// In fa, this message translates to:
  /// **'نرمال'**
  String get labTestFlagNone;

  /// No description provided for @parameterNameRequiredError.
  ///
  /// In fa, this message translates to:
  /// **'نام پارامتر نمی‌تواند خالی باشد'**
  String get parameterNameRequiredError;

  /// No description provided for @parameterValueRequiredError.
  ///
  /// In fa, this message translates to:
  /// **'مقدار پارامتر نمی‌تواند خالی باشد'**
  String get parameterValueRequiredError;

  /// No description provided for @parameterInvalidNumberError.
  ///
  /// In fa, this message translates to:
  /// **'مقدار عددی معتبر وارد کنید'**
  String get parameterInvalidNumberError;

  /// No description provided for @parameterCreatedSuccess.
  ///
  /// In fa, this message translates to:
  /// **'پارامتر با موفقیت اضافه شد'**
  String get parameterCreatedSuccess;

  /// No description provided for @parameterUpdatedSuccess.
  ///
  /// In fa, this message translates to:
  /// **'پارامتر با موفقیت به‌روزرسانی شد'**
  String get parameterUpdatedSuccess;

  /// No description provided for @parameterDeletedSuccess.
  ///
  /// In fa, this message translates to:
  /// **'پارامتر با موفقیت حذف شد'**
  String get parameterDeletedSuccess;

  /// No description provided for @headerUpdatedSuccess.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات آزمایش با موفقیت به‌روزرسانی شد'**
  String get headerUpdatedSuccess;

  /// No description provided for @darkModeLabel.
  ///
  /// In fa, this message translates to:
  /// **'حالت تاریک'**
  String get darkModeLabel;

  /// No description provided for @darkModeEnabled.
  ///
  /// In fa, this message translates to:
  /// **'فعال'**
  String get darkModeEnabled;

  /// No description provided for @darkModeDisabled.
  ///
  /// In fa, this message translates to:
  /// **'غیرفعال'**
  String get darkModeDisabled;

  /// No description provided for @languageLabel.
  ///
  /// In fa, this message translates to:
  /// **'زبان'**
  String get languageLabel;

  /// No description provided for @languagePersian.
  ///
  /// In fa, this message translates to:
  /// **'فارسی'**
  String get languagePersian;

  /// No description provided for @languageEnglish.
  ///
  /// In fa, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In fa, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageChangeHint.
  ///
  /// In fa, this message translates to:
  /// **'برای اعمال کامل تغییر زبان، برنامه را ری‌استارت کنید.'**
  String get languageChangeHint;

  /// No description provided for @settingsTitle.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get settingsTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In fa, this message translates to:
  /// **'مدیک متاورس یک پلتفرم جامع سلامت دیجیتال است که با استفاده از هوش مصنوعی، به شما کمک می‌کند نتایج آزمایش‌های پزشکی خود را بهتر درک کنید و مسیر سلامت خود را هوشمندانه‌تر مدیریت کنید.'**
  String get aboutDescription;

  /// No description provided for @termsBody.
  ///
  /// In fa, this message translates to:
  /// **'۱. پذیرش شرایط\n\nبا استفاده از اپلیکیشن مدیک متاورس، شما تمامی شرایط و ضوابط این سند را می‌پذیرید.\n\n۲. استفاده از سرویس\n\nاین اپلیکیشن صرفاً جهت اطلاع‌رسانی و کمک به درک بهتر نتایج آزمایش‌ها طراحی شده و جایگزین تشخیص یا تجویز پزشک نیست.\n\n۳. حریم خصوصی\n\nاطلاعات پزشکی شما با بالاترین استانداردهای امنیتی ذخیره و محافظت می‌شود.\n\n۴. محتوای هوش مصنوعی\n\nتحلیل‌های ارائه‌شده توسط هوش مصنوعی ممکن است دارای خطا باشد و نباید مبنای تصمیم‌گیری پزشکی قرار گیرد.\n\n۵. تغییرات\n\nمدیک متاورس حق تغییر این شرایط را در هر زمان محفوظ می‌دارد.'**
  String get termsBody;

  /// No description provided for @referComingSoon.
  ///
  /// In fa, this message translates to:
  /// **'به‌زودی امکان اشتراک‌گذاری برنامه فراهم می‌شود.'**
  String get referComingSoon;

  /// No description provided for @deleteAccountBackendPendingMessage.
  ///
  /// In fa, this message translates to:
  /// **'حذف حساب کاربری نیاز به تأیید هویت شما توسط تیم پشتیبانی دارد. آیا مایل به ادامه هستید؟'**
  String get deleteAccountBackendPendingMessage;

  /// No description provided for @deleteAccountSupportMessage.
  ///
  /// In fa, this message translates to:
  /// **'برای حذف حساب، لطفاً با تیم پشتیبانی تماس بگیرید.'**
  String get deleteAccountSupportMessage;

  /// No description provided for @packageStatusActive.
  ///
  /// In fa, this message translates to:
  /// **'فعال'**
  String get packageStatusActive;

  /// No description provided for @packageStatusExpired.
  ///
  /// In fa, this message translates to:
  /// **'منقضی شده'**
  String get packageStatusExpired;

  /// No description provided for @packageStatusCancelled.
  ///
  /// In fa, this message translates to:
  /// **'لغو شده'**
  String get packageStatusCancelled;

  /// No description provided for @blogScreenTitle.
  ///
  /// In fa, this message translates to:
  /// **'مقالات سلامت'**
  String get blogScreenTitle;

  /// No description provided for @blogAllCategories.
  ///
  /// In fa, this message translates to:
  /// **'همه'**
  String get blogAllCategories;

  /// No description provided for @blogPostEmpty.
  ///
  /// In fa, this message translates to:
  /// **'هنوز مطلبی منتشر نشده'**
  String get blogPostEmpty;

  /// No description provided for @blogCategoryEmpty.
  ///
  /// In fa, this message translates to:
  /// **'در این دسته مطلبی وجود ندارد'**
  String get blogCategoryEmpty;

  /// No description provided for @blogDetailTitle.
  ///
  /// In fa, this message translates to:
  /// **'جزئیات مقاله'**
  String get blogDetailTitle;

  /// No description provided for @blogCategoriesTitle.
  ///
  /// In fa, this message translates to:
  /// **'دسته‌بندی‌ها'**
  String get blogCategoriesTitle;

  /// No description provided for @blogPublishedOn.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ انتشار'**
  String get blogPublishedOn;

  /// No description provided for @blogReadMore.
  ///
  /// In fa, this message translates to:
  /// **'ادامه مطلب'**
  String get blogReadMore;

  /// No description provided for @blogLoadMoreFailed.
  ///
  /// In fa, this message translates to:
  /// **'خطا در بارگذاری مطالب'**
  String get blogLoadMoreFailed;

  /// No description provided for @selectInternationalEthnicityTitle.
  ///
  /// In fa, this message translates to:
  /// **'قومیت'**
  String get selectInternationalEthnicityTitle;

  /// No description provided for @selectLocalEthnicityTitle.
  ///
  /// In fa, this message translates to:
  /// **'زیرقومیت'**
  String get selectLocalEthnicityTitle;

  /// No description provided for @pleaseSelectInternationalEthnicityError.
  ///
  /// In fa, this message translates to:
  /// **'لطفا ابتدا قومیت را انتخاب کنید'**
  String get pleaseSelectInternationalEthnicityError;

  /// No description provided for @addNewItemLabel.
  ///
  /// In fa, this message translates to:
  /// **'نام مورد جدید'**
  String get addNewItemLabel;

  /// No description provided for @addNewItemTitle.
  ///
  /// In fa, this message translates to:
  /// **'افزودن {title} جدید'**
  String addNewItemTitle(String title);

  /// No description provided for @addNewItemTooltip.
  ///
  /// In fa, this message translates to:
  /// **'افزودن مورد جدید'**
  String get addNewItemTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
