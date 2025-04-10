import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/providers/admin/space_admin_viewmodel.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class MySpacesPage extends StatefulWidget {
  const MySpacesPage({super.key});

  @override
  State<MySpacesPage> createState() => _MySpacesPageState();
}

class _MySpacesPageState extends State<MySpacesPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpaceAdminViewmodel>().getMySpaces();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpaceAdminViewmodel>();
    final mySpaces = context.watch<SpaceAdminViewmodel>().mySpaces;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Spaces'),
      ),
      body: mySpaces.isEmpty
          ? const Center(child: Text('You Dont Have Any Spaces'))
          : provider.isLoading
              ? const Center(
                  child: CupertinoActivityIndicator(),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: mySpaces.length,
                  itemBuilder: (context, index) {
                    final mySpace = mySpaces[index];
                    return SmoothContainer(
                      onTap: () {
                        context.push(
                          '/admin-parking-page',
                          extra: {
                            'spaceId': mySpace.docId,
                            'docId': mySpace.docId,
                          },
                        );
                      },
                      color: textFieldGrey,
                      horizontalPadding: 12,
                      verticalPadding: 10,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        spacing: 20,
                        children: [
                          SmoothContainer(
                            cornerRadius: 12,
                            height: 100,
                            width: 100,
                            color: Colors.amber,
                            child: Image.network(
                              mySpace.spaceThumbnail[0],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(mySpace.spaceName),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
