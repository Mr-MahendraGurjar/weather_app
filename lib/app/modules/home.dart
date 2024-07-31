import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isar/isar.dart';
import 'package:weather_app/app/api/api.dart';
import 'package:weather_app/app/api/city.dart';
import 'package:weather_app/app/api/constants/constants.dart';
import 'package:weather_app/app/controller/controller.dart';
import 'package:weather_app/app/data/weather.dart';
import 'package:weather_app/app/modules/geolocation.dart';
import 'package:weather_app/app/modules/main/view/weather_page.dart';
import 'package:weather_app/app/services/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool visible = false;
  final _focusNode = FocusNode();
  final weatherController = Get.put(WeatherController());
  final _controller = TextEditingController();

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    await weatherController.deleteCache();
    await weatherController.updateCacheCard(false);
    await weatherController.setLocation();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final labelLarge = textTheme.labelLarge;

    return ScaffoldMessenger(
        key: globalKey,
        child: Scaffold(
            appBar: AppBar(
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                    onPressed: () => Get.to(() => const SelectGeolocation(isStart: false),
                        transition: Transition.downToUp),
                    icon: const Icon(Iconsax.global_search, size: 18)),
                title: visible
                    ? RawAutocomplete<Result>(
                        focusNode: _focusNode,
                        textEditingController: _controller,
                        fieldViewBuilder: (_, __, ___, ____) {
                          return TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              autofocus: true,
                              style: labelLarge?.copyWith(fontSize: 16),
                              decoration: InputDecoration(hintText: 'search'.tr));
                        },
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Result>.empty();
                          }
                          return WeatherAPI().getCity(textEditingValue.text, locale);
                        },
                        onSelected: (Result selection) async {
                          await weatherController.deleteAll(true);
                          await weatherController.getLocation(
                            double.parse('${selection.latitude}'),
                            double.parse('${selection.longitude}'),
                            selection.admin1,
                            selection.name,
                          );
                          visible = false;
                          _controller.clear();
                          _focusNode.unfocus();
                          setState(() {});
                        },
                        displayStringForOption: (Result option) => '${option.name}, ${option.admin1}',
                        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Result> onSelected,
                            Iterable<Result> options) {
                          return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                  borderRadius: BorderRadius.circular(20),
                                  elevation: 4.0,
                                  child: SizedBox(
                                      width: 250,
                                      child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            final Result option = options.elementAt(index);
                                            return InkWell(
                                                onTap: () => onSelected(option),
                                                child: ListTile(
                                                    title: Text('${option.name}, ${option.admin1}',
                                                        style: labelLarge)));
                                          }))));
                        })
                    : Obx(() {
                        final location = weatherController.location;
                        final city = location.city;
                        final district = location.district;
                        return Text(
                            weatherController.isLoading.isFalse
                                ? district!.isEmpty
                                    ? '$city'
                                    : city!.isEmpty
                                        ? district
                                        : city == district
                                            ? city
                                            : '$city' ', $district'
                                : settings.location
                                    ? 'search'.tr
                                    : (isar.locationCaches.where().findAllSync()).isNotEmpty
                                        ? 'loading'.tr
                                        : 'searchCity'.tr,
                            style:
                                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 18));
                      }),
                actions: [
                  IconButton(
                      onPressed: () {
                        if (visible) {
                          _controller.clear();
                          _focusNode.unfocus();
                          visible = false;
                        } else {
                          visible = true;
                        }
                        setState(() {});
                      },
                      icon: Icon(visible ? Icons.close : Iconsax.search_normal_1, size: 18))
                ]),
            body: const SafeArea(child: WeatherPage())));
  }
}
