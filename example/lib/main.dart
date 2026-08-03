import 'package:flutter/widgets.dart';
import 'package:xp_dart/xp_dart.dart';

void main() {
  runApp(const XPExampleApp());
}

/// Main Example Application porting the official XP.css documentation page into Flutter.
class XPExampleApp extends StatelessWidget {
  const XPExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'XP.css - A design system for building faithful recreations of old UIs',
      color: XPColors.surface,
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) {
            return const XPSurface(
              child: XPDocumentationPage(),
            );
          },
        );
      },
    );
  }
}

class XPDocumentationPage extends StatefulWidget {
  const XPDocumentationPage({super.key});

  @override
  State<XPDocumentationPage> createState() => _XPDocumentationPageState();
}

class _XPDocumentationPageState extends State<XPDocumentationPage> {
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _treeScrollController = ScrollController();

  String _selectedNav = 'Intro';

  // Section GlobalKeys for smooth scrolling
  final Map<String, GlobalKey> _sectionKeys = {
    'Intro': GlobalKey(),
    'Components': GlobalKey(),
    'Button': GlobalKey(),
    'Checkbox': GlobalKey(),
    'OptionButton': GlobalKey(),
    'Tabs': GlobalKey(),
    'GroupBox': GlobalKey(),
    'TextBox': GlobalKey(),
    'Slider': GlobalKey(),
    'Dropdown': GlobalKey(),
    'Window': GlobalKey(),
    'Title Bar': GlobalKey(),
    'Window contents': GlobalKey(),
    'Status Bar': GlobalKey(),
    'TreeView': GlobalKey(),
    'ProgressBar': GlobalKey(),
    'Issues, Contributing, etc.': GlobalKey(),
  };

  void _scrollToSection(String label) {
    final key = _sectionKeys[label];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Demo States
  bool _checkbox1 = false;
  bool _checkboxChecked = true;
  bool _checkboxDisabled = false;
  bool _checkboxCheckedDisabled = true;

  String _radioGroup1 = 'Yes';
  String _radioGroup2 = 'Peanut butter should be smooth';
  String _fieldsetRadio = 'Claire Saffitz';

  int _selectedTabA = 0;

  double _volumeSlider = 5.0;
  double _cowbellSlider = 2.0;

  String _rating1 = '5 - Incredible!';

  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _mainScrollController.dispose();
    _treeScrollController.dispose();
    _occupationController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return XPWindow(
      margin: const EdgeInsets.all(16.0),
      titleText:
          'XP.css - A design system for building faithful recreations of old UIs',
      statusBar: const XPStatusBar(
        fields: [
          XPStatusBarField(child: Text('Press F1 for help')),
          XPStatusBarField(child: Text('Slide 1')),
          XPStatusBarField(child: Text('CPU Usage: 14%')),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar Tree Navigation with Scrollbar
          SizedBox(
            width: 200,
            child: XPWindowBody(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      'Active Section: $_selectedNav',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        fontFamily: 'Arial',
                        color: Color(0xFF2267CB),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: XPScrollbar(
                      controller: _treeScrollController,
                      child: SingleChildScrollView(
                        controller: _treeScrollController,
                        child: XPTreeView(
                          height: null,
                          onItemTap: (item) {
                            setState(() => _selectedNav = item.label);
                            _scrollToSection(item.label);
                          },
                          items: const [
                            XPTreeItem(label: 'Intro'),
                            XPTreeItem(
                              label: 'Components',
                              isExpanded: true,
                              children: [
                                XPTreeItem(label: 'Button'),
                                XPTreeItem(label: 'Checkbox'),
                                XPTreeItem(label: 'OptionButton'),
                                XPTreeItem(label: 'Tabs'),
                                XPTreeItem(label: 'GroupBox'),
                                XPTreeItem(label: 'TextBox'),
                                XPTreeItem(label: 'Slider'),
                                XPTreeItem(label: 'Dropdown'),
                                XPTreeItem(
                                  label: 'Window',
                                  isExpanded: true,
                                  children: [
                                    XPTreeItem(label: 'Title Bar'),
                                    XPTreeItem(label: 'Window contents'),
                                    XPTreeItem(label: 'Status Bar'),
                                  ],
                                ),
                                XPTreeItem(label: 'TreeView'),
                                XPTreeItem(label: 'ProgressBar'),
                              ],
                            ),
                            XPTreeItem(label: 'Issues, Contributing, etc.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const XPVerticalDivider(),

          // Main Documentation Body with Scrollbar
          Expanded(
            child: XPWindowBody(
              padding: const EdgeInsets.all(12.0),
              child: XPScrollbar(
                controller: _mainScrollController,
                child: SingleChildScrollView(
                  controller: _mainScrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'XP.css',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Arial',
                          color: Color(0xFF000000),
                        ),
                      ),
                      _buildRainbowDivider(),
                      const Text(
                        'A design system for building faithful recreations of old UIs.',
                        style: TextStyle(fontSize: 12, fontFamily: 'Arial'),
                      ),
                      const SizedBox(height: 16),

                      // Intro Section
                      _buildSectionHeader('Intro', key: _sectionKeys['Intro']),
                      const Text(
                        'XP.css is a CSS library for building interfaces that look like Windows XP.',
                        style: TextStyle(fontSize: 11, fontFamily: 'Arial'),
                      ),
                      const SizedBox(height: 12),

                      // Demo Window ("My First Program")
                      Center(
                        child: XPWindow(
                          width: 260,
                          titleText: 'My First Program',
                          child: XPWindowBody(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Hello, world!'),
                                const SizedBox(height: 16),
                                XPFieldRow(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    XPButton(label: 'OK', onPressed: () {}),
                                    XPButton(label: 'Cancel', onPressed: () {}),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Components Header
                      _buildSectionHeader('Components', key: _sectionKeys['Components']),

                      // 1. Button Component
                      _buildComponentCard(
                        key: _sectionKeys['Button'],
                        title: 'Button',
                        quote:
                            'A command button, also referred to as a push button, is a control that causes the application to perform some action when the user clicks it.\n— Microsoft Windows User Experience p. 160',
                        description:
                            'A standard button measures 75px wide and 23px tall, with a raised outer and inner border.',
                        demo: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            XPFieldRow(
                              children: [
                                const Text('Standard: '),
                                XPButton(label: 'Click me', onPressed: () {}),
                              ],
                            ),
                            const SizedBox(height: 10),
                            XPFieldRow(
                              children: [
                                const Text('Disabled: '),
                                const XPButton(
                                    label: 'I cannot be clicked', enabled: false),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 2. Checkbox Component
                      _buildComponentCard(
                        key: _sectionKeys['Checkbox'],
                        title: 'Checkbox',
                        quote:
                            'A check box represents an independent or non-exclusive choice.\n— Microsoft Windows User Experience p. 167',
                        description:
                            'Checkboxes are represented with a sunken panel, populated with a check icon when selected.',
                        demo: XPFieldRowStacked(
                          children: [
                            XPCheckbox(
                              value: _checkbox1,
                              label: 'This is a checkbox',
                              onChanged: (val) =>
                                  setState(() => _checkbox1 = val),
                            ),
                            XPCheckbox(
                              value: _checkboxChecked,
                              label: 'I am checked',
                              onChanged: (val) =>
                                  setState(() => _checkboxChecked = val),
                            ),
                            XPCheckbox(
                              value: _checkboxDisabled,
                              enabled: false,
                              label: 'I am inactive',
                              onChanged: (val) =>
                                  setState(() => _checkboxDisabled = val),
                            ),
                            XPCheckbox(
                              value: _checkboxCheckedDisabled,
                              enabled: false,
                              label: 'I am inactive but still checked',
                              onChanged: (val) => setState(
                                  () => _checkboxCheckedDisabled = val),
                            ),
                          ],
                        ),
                      ),

                      // 3. OptionButton (Radio) Component
                      _buildComponentCard(
                        key: _sectionKeys['OptionButton'],
                        title: 'OptionButton',
                        quote:
                            'An option button, also referred to as a radio button, represents a single choice within a limited set of mutually exclusive choices.\n— Microsoft Windows User Experience p. 164',
                        description:
                            'Option buttons can be grouped to provide mutually exclusive selection.',
                        demo: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            XPFieldRowStacked(
                              children: [
                                XPRadioButton<String>(
                                  value: 'Yes',
                                  groupValue: _radioGroup1,
                                  label: 'Yes',
                                  onChanged: (val) {
                                    if (val != null) setState(() => _radioGroup1 = val);
                                  },
                                ),
                                XPRadioButton<String>(
                                  value: 'No',
                                  groupValue: _radioGroup1,
                                  label: 'No',
                                  onChanged: (val) {
                                    if (val != null) setState(() => _radioGroup1 = val);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            XPFieldRowStacked(
                              children: [
                                XPRadioButton<String>(
                                  value: 'Peanut butter should be smooth',
                                  groupValue: _radioGroup2,
                                  label: 'Peanut butter should be smooth',
                                  onChanged: (val) {
                                    if (val != null) setState(() => _radioGroup2 = val);
                                  },
                                ),
                                XPRadioButton<String>(
                                  value:
                                      'I understand why people like crunchy peanut butter',
                                  groupValue: _radioGroup2,
                                  enabled: false,
                                  label:
                                      'I understand why people like crunchy peanut butter (Disabled)',
                                  onChanged: (val) {
                                    if (val != null) setState(() => _radioGroup2 = val);
                                  },
                                ),
                                XPRadioButton<String>(
                                  value: 'Crunchy peanut butter is good',
                                  groupValue: _radioGroup2,
                                  enabled: false,
                                  label:
                                      'Crunchy peanut butter is good (Disabled)',
                                  onChanged: (val) {
                                    if (val != null) setState(() => _radioGroup2 = val);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 4. Tabs Component
                      _buildComponentCard(
                        key: _sectionKeys['Tabs'],
                        title: 'Tabs',
                        quote:
                            'Tabs provide a way to present related information on separate labeled pages.\n— Microsoft Windows User Experience Guidelines',
                        description:
                            'Tabbed container organizing controls across pages.',
                        demo: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: XPTabs(
                            selectedIndex: _selectedTabA,
                            onTabSelected: (idx) =>
                                setState(() => _selectedTabA = idx),
                            tabs: [
                              const XPTab(
                                label: 'Tab A',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tab Content A',
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                        'Recreated faithfully from official XP.css styles.'),
                                  ],
                                ),
                              ),
                              XPTab(
                                label: 'Tab B',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tab Content B',
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    XPGroupBox(
                                      label: "Today's mood",
                                      child: XPFieldRowStacked(
                                        children: [
                                          XPRadioButton<String>(
                                            value: 'Claire Saffitz',
                                            groupValue: _fieldsetRadio,
                                            label: 'Claire Saffitz',
                                            onChanged: (val) {
                                              if (val != null) setState(() => _fieldsetRadio = val);
                                            },
                                          ),
                                          XPRadioButton<String>(
                                            value: 'Brad Leone',
                                            groupValue: _fieldsetRadio,
                                            label: 'Brad Leone',
                                            onChanged: (val) {
                                              if (val != null) setState(() => _fieldsetRadio = val);
                                            },
                                          ),
                                          XPRadioButton<String>(
                                            value: 'Chris Morocco',
                                            groupValue: _fieldsetRadio,
                                            label: 'Chris Morocco',
                                            onChanged: (val) {
                                              if (val != null) setState(() => _fieldsetRadio = val);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const XPTab(
                                label: 'Tab C',
                                child: Text(
                                    'Tab Content C: Lorem Ipsum Dolor Sit Amet'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 5. GroupBox Component
                      _buildComponentCard(
                        key: _sectionKeys['GroupBox'],
                        title: 'GroupBox',
                        quote:
                            'A group box is a special control you can use to organize a set of controls.\n— Microsoft Windows User Experience p. 189',
                        description:
                            'Encloses a set of controls with an engraved 1px border and optional legend title.',
                        demo: XPGroupBox(
                          label: 'Food Preferences',
                          child: XPFieldRowStacked(
                            children: [
                              const Text('Select one option:'),
                              XPRadioButton<String>(
                                value: 'Diners',
                                groupValue: _fieldsetRadio,
                                label: 'Diners',
                                onChanged: (val) {
                                  if (val != null) setState(() => _fieldsetRadio = val);
                                },
                              ),
                              XPRadioButton<String>(
                                value: 'Drive-Ins',
                                groupValue: _fieldsetRadio,
                                label: 'Drive-Ins',
                                onChanged: (val) {
                                  if (val != null) setState(() => _fieldsetRadio = val);
                                },
                              ),
                              XPRadioButton<String>(
                                value: 'Dives',
                                groupValue: _fieldsetRadio,
                                label: 'Dives',
                                onChanged: (val) {
                                  if (val != null) setState(() => _fieldsetRadio = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 6. TextBox Component
                      _buildComponentCard(
                        key: _sectionKeys['TextBox'],
                        title: 'TextBox',
                        quote:
                            'A text box is a rectangular control where the user enters or edits text.\n— Microsoft Windows User Experience p. 181',
                        description:
                            'Single-line input and multi-line text area.',
                        demo: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            XPFieldRow(
                              children: [
                                const Text('Occupation: '),
                                Expanded(
                                  child: XPTextField(
                                    controller: _occupationController,
                                    placeholder: 'Enter occupation...',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            XPFieldRowStacked(
                              width: 250,
                              children: [
                                const Text('Address (Line 1):'),
                                XPTextField(controller: _address1Controller),
                                const Text('Address (Line 2):'),
                                XPTextField(controller: _address2Controller),
                              ],
                            ),
                            const SizedBox(height: 12),
                            XPFieldRowStacked(
                              width: 250,
                              children: [
                                const Text('Additional notes:'),
                                XPTextArea(
                                  controller: _notesController,
                                  height: 60,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 7. Slider Component
                      _buildComponentCard(
                        key: _sectionKeys['Slider'],
                        title: 'Slider',
                        quote:
                            'A slider consists of a bar that defines the extent of adjustment and an indicator.\n— Microsoft Windows User Experience p. 146',
                        description:
                            'Horizontal and vertical range controls with pointer or box thumb.',
                        demo: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            XPFieldRow(
                              children: [
                                const Text('Volume: '),
                                const Text('Low '),
                                SizedBox(
                                  width: 160,
                                  child: XPSlider(
                                    value: _volumeSlider,
                                    min: 1.0,
                                    max: 11.0,
                                    onChanged: (val) =>
                                        setState(() => _volumeSlider = val),
                                  ),
                                ),
                                const Text(' High'),
                                Text(' (${_volumeSlider.toInt()})'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            XPFieldRow(
                              children: [
                                const Text('Cowbell Vertical: '),
                                XPSlider(
                                  value: _cowbellSlider,
                                  min: 1.0,
                                  max: 3.0,
                                  isVertical: true,
                                  hasBoxIndicator: true,
                                  onChanged: (val) =>
                                      setState(() => _cowbellSlider = val),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 8. Dropdown Component
                      _buildComponentCard(
                        key: _sectionKeys['Dropdown'],
                        title: 'Dropdown',
                        quote:
                            'A drop-down list box allows selection of a single item from a list.\n— Microsoft Windows User Experience p. 175',
                        description:
                            'Select element displaying items in a popup overlay menu.',
                        demo: XPFieldRow(
                          children: [
                            const Text('Rating: '),
                            SizedBox(
                              width: 180,
                              child: XPDropdown<String>(
                                value: _rating1,
                                items: const [
                                  XPDropdownItem(
                                      value: '5 - Incredible!',
                                      label: '5 - Incredible!'),
                                  XPDropdownItem(
                                      value: '4 - Great!', label: '4 - Great!'),
                                  XPDropdownItem(
                                      value: '3 - Pretty good',
                                      label: '3 - Pretty good'),
                                  XPDropdownItem(
                                      value: '2 - Not so great',
                                      label: '2 - Not so great'),
                                  XPDropdownItem(
                                      value: '1 - Unfortunate',
                                      label: '1 - Unfortunate'),
                                ],
                                onChanged: (val) =>
                                    setState(() => _rating1 = val!),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 9. Window Demos
                      _buildComponentCard(
                        key: _sectionKeys['Window'],
                        title: 'Window',
                        quote:
                            'At the top edge of the window is the title bar. At the bottom is the status bar.\n— Microsoft Windows User Experience',
                        description:
                            'Complete Windows with title bar controls, body, and status bar.',
                        demo: Column(
                          key: _sectionKeys['Window contents'],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Title Bar', key: _sectionKeys['Title Bar']),
                            const SizedBox(height: 6),
                            XPWindow(
                              width: 320,
                              titleText: 'Command Prompt Window',
                              statusBar: XPStatusBar(
                                key: _sectionKeys['Status Bar'],
                                fields: const [
                                  XPStatusBarField(child: Text('Press F1 for help')),
                                  XPStatusBarField(child: Text('Slide 1')),
                                  XPStatusBarField(child: Text('CPU: 14%')),
                                ],
                              ),
                              child: XPWindowBody(
                                child: Container(
                                  color: const Color(0xFF000000),
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    'Microsoft(R) Windows XP [Version 5.1.2600]\n(C) Copyright 1985-2001 Microsoft Corp.\n\nC:\\> dir',
                                    style: TextStyle(
                                      fontFamily: 'Courier',
                                      color: Color(0xFFC0C0C0),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 10. TreeView Component
                      _buildComponentCard(
                        key: _sectionKeys['TreeView'],
                        title: 'TreeView',
                        quote:
                            'A tree view control displays a set of objects as an indented outline.\n— Microsoft Windows User Experience p. 178',
                        description:
                            'Hierarchical tree with dotted connecting lines and toggle boxes.',
                        demo: const SizedBox(
                          height: 160,
                          width: 300,
                          child: XPTreeView(
                            items: [
                              XPTreeItem(
                                label: 'Table of Contents',
                                isExpanded: true,
                                children: [
                                  XPTreeItem(label: 'Introduction'),
                                  XPTreeItem(
                                    label: 'Core Concepts',
                                    isExpanded: true,
                                    children: [
                                      XPTreeItem(label: 'Selectors'),
                                      XPTreeItem(label: 'Layout'),
                                      XPTreeItem(label: 'Controls'),
                                    ],
                                  ),
                                  XPTreeItem(label: 'Summary'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 11. ProgressBar Component
                      _buildComponentCard(
                        key: _sectionKeys['ProgressBar'],
                        title: 'ProgressBar',
                        quote:
                            'With a progress bar, users can follow the progress of an operation.\n— Microsoft Windows User Experience Guidelines',
                        description:
                            'Determinate and sliding indeterminate green progress bar.',
                        demo: const XPFieldRowStacked(
                          children: [
                            Text('Determinate (70%):'),
                            XPProgressBar(value: 0.70),
                            SizedBox(height: 10),
                            Text('Indeterminate (Ongoing Activity):'),
                            XPProgressBar(value: null),
                          ],
                        ),
                      ),

                      // Footer / Contributing
                      _buildSectionHeader('Issues, Contributing, etc.',
                          key: _sectionKeys['Issues, Contributing, etc.']),
                      const Text(
                        'XP.css is open-source under the MIT license.\n'
                        'Thank you for using XP.css!',
                        style: TextStyle(fontSize: 11, fontFamily: 'Arial'),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRainbowDivider() {
    return Container(
      height: 1,
      width: 400,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF0000), Color(0xFFFF0000),
            Color(0xFFFFFF00), Color(0xFFFFFF00),
            Color(0xFF008000), Color(0xFF008000),
            Color(0xFF0000FF), Color(0xFF0000FF),
          ],
          stops: [0.0, 0.20, 0.20, 0.36, 0.36, 0.60, 0.60, 1.0],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
            color: Color(0xFF2267CB),
          ),
        ),
        _buildRainbowDivider(),
      ],
    );
  }

  Widget _buildComponentCard({
    Key? key,
    required String title,
    required String quote,
    required String description,
    required Widget demo,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      child: XPGroupBox(
        label: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quote,
              style: const TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAF9),
                border: Border.all(color: const Color(0xFFD0D0BF), width: 1),
              ),
              child: demo,
            ),
          ],
        ),
      ),
    );
  }
}
