import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/models.dart';
import '../views/views.dart';
import '../services/services.dart';

final GoRouter router = GoRouter(
  redirect: (context, state) {
    if (!AuthProvider.of(context).auth.isSignedIn() && state.subloc == "/") {
      return "/";
    }

    return null;
  },
  errorBuilder: (context, state) {
    return Builder(builder: (context) {
      return Scaffold(
        body: NoDataFound(
          text:
              "Error 404. Page Not Found\nPlease press the button below to report this error to us so we can fix it.",
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            FeedbackServices().startFeedingBackward(
              context,
              ThingType.PROPERTYMANAGER,
            );
          },
          icon: Icon(
            FontAwesomeIcons.bug,
          ),
          label: Text(
            "Report this error",
          ),
        ),
      );
    });
  },
  routes: [
    //splash
    GoRoute(
      name: RouteConstants.splash,
      path: "/",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: SplashScreenView(),
        );
      },
    ),
    //about us
    GoRoute(
      name: RouteConstants.aboutUs,
      path: "/${RouteConstants.aboutUs}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: AboutUs(),
        );
      },
    ),

    //dash and home
    GoRoute(
      name: RouteConstants.home,
      path: "/${RouteConstants.home}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: Dashboard(),
        );
      },
    ),
    //detailed image
    GoRoute(
      name: RouteConstants.image,
      path: "/${RouteConstants.image}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: DetailedImage(
            images: state.extra,
          ),
        );
      },
    ),
    //detailed property
    GoRoute(
      name: RouteConstants.property,
      path: "/${RouteConstants.property}/:id",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: DetailedPropertyView(
            property: state.extra as Property,
            propertyID: state.params["id"],
          ),
        );
      },
    ),
    //rooms by type
    GoRoute(
      name: RouteConstants.allRoomsInAType,
      path: "/${RouteConstants.allRoomsInAType}/:id",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: AllRoomsInARoomTypeView(
            roomTypeID: state.params["id"],
          ),
        );
      },
    ),
    //detailed food
    GoRoute(
      name: RouteConstants.booking,
      path: "/${RouteConstants.booking}/:id",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: DetailedBooking(
            booking: state.extra as Booking,
            bookingID: state.params["id"],
          ),
        );
      },
    ),
    //notifications
    GoRoute(
      name: RouteConstants.notifications,
      path: "/${RouteConstants.notifications}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: NotificationsView(),
        );
      },
    ),
    //edit user
    GoRoute(
      name: RouteConstants.editUser,
      path: "/${RouteConstants.editUser}",
      pageBuilder: (context, state) {
        UserModel cc;

        if (state.extra != null) {
          cc = state.extra as UserModel;
        }

        return MaterialPage(
          child: EditProfileView(
            user: cc,
            showEmail:
                (state.queryParams["showEmail"] == "true") ? true : false,
          ),
        );
      },
    ),
    //all my properties
    GoRoute(
      name: RouteConstants.allMyProperties,
      path: "/${RouteConstants.allMyProperties}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: AllMyPropertiesView(),
        );
      },
    ),
    //detailed category
    GoRoute(
      name: RouteConstants.expensesByCategory,
      path: "/${RouteConstants.expensesByCategory}/:id",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: ExpensesByCategoryView(
            category: state.params["id"],
            categoryName: state.queryParams["name"],
          ),
        );
      },
    ),
    //bills and expenses
    GoRoute(
      name: RouteConstants.billsAndExpenses,
      path: "/${RouteConstants.billsAndExpenses}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: BillsAndExpensesView(),
        );
      },
    ),
    //all customers
    GoRoute(
      name: RouteConstants.allCustomers,
      path: "/${RouteConstants.allCustomers}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: AllCustomersView(),
        );
      },
    ),
    //reminders
    GoRoute(
      name: RouteConstants.reminders,
      path: "/${RouteConstants.reminders}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: AllRemindersView(),
        );
      },
    ),
    //all rooms
    GoRoute(
      name: RouteConstants.allRooms,
      path: "/${RouteConstants.allRooms}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: AllRoomsView(),
        );
      },
    ),
    //all room types
    GoRoute(
      name: RouteConstants.allRoomTypes,
      path: "/${RouteConstants.allRoomTypes}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: AllRoomTypesView(),
        );
      },
    ),
    //attached food
    GoRoute(
      name: RouteConstants.attachedFoodPlaces,
      path: "/${RouteConstants.attachedFoodPlaces}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: AttachedFoodPlaces(),
        );
      },
    ),
    //all paymnts
    GoRoute(
      name: RouteConstants.allPayments,
      path: "/${RouteConstants.allPayments}/:id",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: PaymentsView(
            viewerType: state.queryParams["type"],
            viewerID: state.params["id"],
          ),
        );
      },
    ),
    //noticeboards
    GoRoute(
      name: RouteConstants.noticeboards,
      path: "/${RouteConstants.noticeboards}",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: NoticeBoardManagemnetView(),
        );
      },
    ),
    //booking details
    GoRoute(
      name: RouteConstants.bookingManagement,
      path: "/${RouteConstants.bookingManagement}/:id",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: HandleBookingView(
            bookingID: state.params["id"],
          ),
        );
      },
    ),
    //user
    GoRoute(
      name: RouteConstants.user,
      path: "/${RouteConstants.user}/:id",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: UserProfileView(
            user: state.extra as UserModel,
            uid: state.params["id"],
          ),
        );
      },
    ),
  ],
);

class RouteConstants {
  static String user = "user";
  static String aboutUs = "aboutUs";
  static String noticeboards = "noticeboards";
  static String splash = "splash";
  static String allPayments = "allPayments";
  static String bookingManagement = "bookingManagement";
  static String allCustomers = "allCustomers";
  static String editUser = "editUser";
  static String allMyProperties = "allMyProperties";
  static String image = "image";
  static String property = "property";
  static String booking = "booking";
  static String food = "food";
  static String allRooms = "allRooms";
  static String attachedFoodPlaces = "attachedFoodPlaces";
  static String allRoomTypes = "allRoomTypes";
  static String expensesByCategory = "expensesByCategory";
  static String billsAndExpenses = "billsAndExpenses";
  static String allRoomsInAType = "allRoomsInAType";
  static String reminders = "reminders";
  static String home = "home";
  static String notifications = "notifications";
  static String myProfile = "myprofile";
}
