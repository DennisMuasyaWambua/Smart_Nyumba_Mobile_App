
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smart_nyumba/utils/providers/all_transactions.dart';
import 'package:smart_nyumba/utils/providers/get_all_tenants.dart';
import '../utils/providers/_providers.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (context) => Payments()),
  ChangeNotifierProvider(create: (context) => TenantsProfile()),
  ChangeNotifierProvider(create: (context) => Auth()),
  ChangeNotifierProvider(create: (context) => InternetChecker()),
  ChangeNotifierProvider(create: (context) => AdminController()),
  ChangeNotifierProvider(create: (context)=>Tenancy()),
  ChangeNotifierProvider(create: (context)=>AllTransactions()),
];
