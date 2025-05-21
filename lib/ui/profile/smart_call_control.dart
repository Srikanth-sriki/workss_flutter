import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/helper_function.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/models/smartCallModal.dart';
import '../../components/colors.dart';
import '../../models/fetch_profile_model.dart';
import 'modal/smart_call_modal.dart';

class SmartCallControlScreen extends StatefulWidget {
  final List<SmartCallSchedule> smartCallSchedule;
  final String smartCallControl;

  const SmartCallControlScreen({
    super.key,
    required this.smartCallControl,
    required this.smartCallSchedule,
  });

  @override
  _SmartCallControlScreenState createState() => _SmartCallControlScreenState();
}

class _SmartCallControlScreenState extends State<SmartCallControlScreen> {
  String selectedMode = "Available Anytime";
  bool hasChanges = false;

  List<SmartCallSchedule> schedule = [];

  String _formatIfNeeded(String timeStr) {
    try {
      // Try parsing 24-hour time (like "14:30")
      final dt = DateFormat("HH:mm").parseStrict(timeStr);
      return DateFormat.jm().format(dt); // returns "2:30 PM"
    } catch (_) {
      try {
        // If already 12-hour format, just normalize (e.g., fix casing)
        final dt = DateFormat.jm().parseLoose(timeStr);
        return DateFormat.jm().format(dt);
      } catch (_) {
        // If format is invalid or unknown, just return original
        return timeStr;
      }
    }
  }


  @override
  void initState() {
    super.initState();
    selectedMode = _mapControlValue(widget.smartCallControl);
    schedule = widget.smartCallSchedule.map((item) {
      return SmartCallSchedule(
        day: item.day,
        fromTime: _formatIfNeeded(item.fromTime ?? "12:00"),
        toTime: _formatIfNeeded(item.toTime ?? "19:00"),
        status: item.status ?? false,
      );

    }).toList();
  }

  String _mapControlValue(String value) {
    switch (value) {
      case 'available_anytime':
        return 'Available Anytime';
      case 'scheduled':
        return 'Set Your Schedule';
      case 'dnd':
        return 'Do Not Disturb';
      default:
        return 'Available Anytime';
    }
  }

  String _mapControlLabel(String label) {
    switch (label) {
      case 'Available Anytime':
        return 'available_anytime';
      case 'Set Your Schedule':
        return 'scheduled';
      case 'Do Not Disturb':
        return 'dnd';
      default:
        return 'available_anytime';
    }
  }

  Future<void> pickTime(BuildContext context, int index, bool isFrom) async {
    final initialTime = isFrom
        ? _parseTime(schedule[index].fromTime!)
        : _parseTime(schedule[index].toTime!);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      barrierDismissible: true,initialEntryMode: TimePickerEntryMode.input,

    );

    if (picked != null) {
      print("Picked time: ${picked.format(context)}"); // Debug log
      final formatted = _formatTime(picked);
      setState(() {
        hasChanges = true;
        if (isFrom) {
          schedule[index].fromTime = formatted;
        } else {
          schedule[index].toTime = formatted;
        }
      });
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parsed = DateFormat.jm().parseLoose(timeStr); // More flexible
      return TimeOfDay.fromDateTime(parsed);
    } catch (_) {
      return const TimeOfDay(hour: 12, minute: 0);
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt); // 12-hour format with AM/PM
  }

  bool isInvalidTimeRange(SmartCallSchedule schedule) {
    try {
      final from = DateFormat.jm().parse(schedule.fromTime ?? "");
      final to = DateFormat.jm().parse(schedule.toTime ?? "");
      return to.isBefore(from);
    } catch (_) {
      return false;
    }
  }

  void onUpdatePressed() {

    print('ddd');
    for (var s in schedule) {
      if ((s.status ?? false) && isInvalidTimeRange(s)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid time range for ${s.day}. Please fix it.")),
        );
        return;
      }
    }

    // Proceed if all valid
    final model = SmartCallSettings(
      smartCallControl: _mapControlLabel(selectedMode),
      smartCallSchedule: schedule,
    );

    final json = smartCallSettingsToJson(model);
    print("Submitted JSON: $json");

    setState(() {
      hasChanges = false;
    });

    showMaterialModalBottomSheet(
      enableDrag: true,
      expand: false,
      isDismissible: true,
      backgroundColor: COLORS.white,
      context: context,
      closeProgressThreshold: 0,
      duration: const Duration(seconds: 0),
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (context) => SmartCallModal(
      buttonText: 'UPDATE',
      header:
      'Your Smart Call settings have been modified. Do you want to save these changes?',
      backgroundColor: COLORS.primary,
        onPress: (){},

    ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: COLORS.white,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: SizeConfig.blockHeight*2,horizontal: SizeConfig.blockWidth*4.5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_ios_outlined,
                    color: COLORS.neutralDark,
                    size: SizeConfig.blockWidth * 4,
                  ),
                  SizedBox(width: SizeConfig.blockWidth*4,),
                  Text(
                    'Smart Call Control',
                    style: TextStyle(
                      color: COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 3.8,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
              SizedBox(width: SizeConfig.blockHeight),
              Padding(
                padding: EdgeInsets.only(left: SizeConfig.blockWidth*8),
                child: Text(
                  'Easily enable or disable call permissions and set specific time windows to prioritize when calls can be received. Customize your availability to stay in control without missing what matters.',
                  style: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 3.25,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                  softWrap: true,
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight*4,),
              _buildModeTile("Available Anytime",false,"Receive calls 24/7 without any restrictions — you’re always reachable."),
              SizedBox(height: SizeConfig.blockHeight*2,),
              _buildModeTile("Set Your Schedule",true,"Choose specific days and time slots to receive calls that suit your routine."),
              SizedBox(height: SizeConfig.blockHeight*2,),
              _buildModeTile("Do Not Disturb",false,"Block all incoming calls to focus on your work or personal time."),

            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(top: SizeConfig.blockHeight * 1.5),
        padding: EdgeInsets.only(
            top: SizeConfig.blockHeight * 2.5,
            bottom: SizeConfig.blockHeight * 1),
        decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(
                    color: COLORS.neutralDarkOne, width: 0.1))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            customButton(
              text: 'DISCARD'.tr(),
              onPressed: () {
                showMaterialModalBottomSheet(
                  enableDrag: true,
                  expand: false,
                  isDismissible: true,
                  backgroundColor: COLORS.white,
                  context: context,
                  closeProgressThreshold: 0,
                  duration: const Duration(seconds: 0),
                  useRootNavigator: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20)),
                  ),
                  builder: (context) => SmartCallModal(
                    buttonText: 'DISCARD',
                    header:
                    'You have unsaved changes. Are you sure you want to discard them?',
                    backgroundColor: COLORS.semantic,
                    onPress: (){
                      setState(() {});
                      Navigator.pop(context);
                    },

                  ),
                );

              },
              backgroundColor: COLORS.neutralDarkTwo,
              showIcon: false,
              width: SizeConfig.blockWidth * 42,
              height: SizeConfig.blockHeight * 8,
              textColor: COLORS.neutralDark,
            ),
            customButton(
              text: 'UPDATE'.tr(),
              onPressed: () {
                hasChanges ? onUpdatePressed() : null;
              },
              backgroundColor: COLORS.primary,
              showIcon: false,
              width: SizeConfig.blockWidth * 42,
              height: SizeConfig.blockHeight * 8,
              textColor: COLORS.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTile(String mode,bool visibleList,String subText) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockHeight,
        horizontal: SizeConfig.blockWidth * 4,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: COLORS.neutralDarkTwo,
          width: SizeConfig.blockWidth * 0.2,
        ),
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RadioListTile<String>(
            title: Text(
              mode,
              style: TextStyle(
                color: COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 3.5,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
            ),
            value: mode,
            groupValue: selectedMode,
            contentPadding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return COLORS.primary;
              }
              return COLORS.neutralDarkOne;
            }),
            dense: true,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedMode = value;
                  hasChanges = true;
                });
              }
            }, toggleable: true,
          ),
          Padding(
            padding: EdgeInsets.only(left: SizeConfig.blockWidth*16),
            child: Text(
              subText,
              style: TextStyle(
                color: COLORS.neutralDarkOne,
                fontSize: SizeConfig.blockWidth * 3,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
              softWrap: true,
            ),
          ),

          if (selectedMode == "Set Your Schedule" && visibleList)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: schedule.length,
              itemBuilder: (_, index) => _buildDayRow(index),
            ),
        ],
      ),
    );
  }


  Widget _buildDayRow(int index) {
    final item = schedule[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            capitalizeFirstLetter(item.day!).substring(0, 3),
            style: TextStyle(
              color: COLORS.neutralDark,
              fontSize: SizeConfig.blockWidth * 3.5,
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins",
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () => pickTime(context, index, true),
                  child: _timeField(item.fromTime ?? ""),
                ),
              ),
             SizedBox(width: SizeConfig.blockWidth*3,),

              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () => pickTime(context, index, false),
                  child: _timeField(item.toTime ?? ""),
                ),
              ),
              SizedBox(width: SizeConfig.blockWidth,),

              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: item.status ?? false,
                  onChanged: (val) {
                    setState(() {
                      hasChanges = true;
                      item.status = val;
                    });
                  },
                  activeColor: COLORS.primaryOne,
                  activeTrackColor: COLORS.primary,
                  inactiveThumbColor: COLORS.neutralDarkOne,
                  inactiveTrackColor: COLORS.white,

                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeField(String time) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(time),
        padding:  EdgeInsets.symmetric(vertical: SizeConfig.blockHeight*1.5),
        decoration: BoxDecoration(
          border: Border.all(color: COLORS.neutralDarkTwo,width: SizeConfig.blockWidth*0.2),
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth*3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(time,
              style: TextStyle(
                color: COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 3.25,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(width: SizeConfig.blockWidth*3,),
            Icon(Icons.access_time_sharp,color: COLORS.accent,size: SizeConfig.blockWidth*4.25,)
          ],
        ),
      ),
    );
  }
}
