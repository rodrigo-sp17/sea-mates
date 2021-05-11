import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/data/friend.dart';
import 'package:sea_mates/model/friend_list_model.dart';

class FriendView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FriendViewState();
}

class _FriendViewState extends State<FriendView> {
  final String title = "Friends";

  Future<void> _requestFriendship(String username) async {
    var message = await Provider.of<FriendListModel>(context, listen: false)
        .requestFriendship(username);

    if (message != null) {
      _showSnackbar(context, message);
    } else {
      _showSnackbar(context, "Friendship requested!");
    }
  }

  Future<void> _acceptFriendship(String username) async {
    var message = await Provider.of<FriendListModel>(context, listen: false)
        .acceptFriendship(username);

    if (message != null) {
      _showSnackbar(context, message);
    } else {
      _showSnackbar(context, "Friendship accepted!");
    }
  }

  Future<void> _removeFriendship(String username) async {
    var proceed = await _showUnfriendDialog(context, username);
    if (proceed) {
      var message = await Provider.of<FriendListModel>(context, listen: false)
          .removeFriend(username);

      if (message != null) {
        _showSnackbar(context, message);
      } else {
        _showSnackbar(context, "Unfriended $username!");
      }
    }
  }

  Future<void> _refresh() async {
    var message =
        await Provider.of<FriendListModel>(context, listen: false).refresh();
    if (message != null) {
      _showSnackbar(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                title: Text(title),
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Requests",
                      textScaleFactor: 1.3,
                    ),
                    Divider(
                      height: 10,
                      thickness: 2,
                    )
                  ],
                ),
              ),
              Consumer<FriendListModel>(
                builder: (context, model, child) {
                  if (!model.isLoading) {
                    var requests = model.otherRequests;
                    return requests.isEmpty
                        ? SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                                (context, int index) {
                              var request = requests[index];
                              return OtherRequestCard(
                                  request, _acceptFriendship);
                            }, childCount: requests.length),
                          );
                  } else {
                    return SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                },
              ),
              Consumer<FriendListModel>(
                builder: (context, model, child) {
                  if (!model.isLoading) {
                    var requests = model.myRequests;
                    return requests.isEmpty
                        ? SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                                (context, int index) {
                              var request = requests[index];
                              return MyRequestCard(request);
                            }, childCount: requests.length),
                          );
                  } else {
                    return SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                },
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Friends",
                      textScaleFactor: 1.3,
                    ),
                    Divider(
                      height: 10,
                      thickness: 2,
                    )
                  ],
                ),
              ),
              Consumer<FriendListModel>(
                builder: (context, model, child) {
                  if (model.isLoading) {
                    return SliverFillRemaining(
                        child: Center(
                      child: CircularProgressIndicator(),
                    ));
                  } else {
                    var friends = model.friends;
                    return friends.isEmpty
                        ? SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                                (context, int index) {
                              var friend = friends[index];
                              return FriendCard(friend, _removeFriendship);
                            }, childCount: friends.length),
                          );
                  }
                },
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                var username = await _showAddFriendDialog(context);
                _requestFriendship(username!);
              }),
        )
      ],
    );
  }
}

class MyRequestCard extends StatelessWidget {
  const MyRequestCard(this.req);

  final FriendRequest req;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(req.targetName),
        subtitle: Text(
            '${req.targetUsername}\nRequested on ${DateFormat.yMd().format(req.timestamp)}'),
        isThreeLine: true,
      ),
    );
  }
}

class OtherRequestCard extends StatelessWidget {
  const OtherRequestCard(this.req, this.acceptCallback);

  final FriendRequest req;
  final Function(String) acceptCallback;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(req.sourceName),
        subtitle: Text(
            '${req.sourceUsername}\n${DateFormat.yMd().format(req.timestamp)}'),
        isThreeLine: true,
        trailing: TextButton(
          onPressed: () => acceptCallback(req.sourceUsername),
          child: Text('ACCEPT'),
        ),
      ),
    );
  }
}

class FriendCard extends StatelessWidget {
  const FriendCard(this.friend, this.removeCallback);
  final Friend friend;
  final Function(String) removeCallback;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
            height: double.infinity,
            child: friend.isAvailable(DateTime.now())
                ? Icon(
                    Icons.home,
                    semanticLabel: 'On land',
                  )
                : Icon(
                    Icons.directions_boat,
                    semanticLabel: "On sea",
                  )),
        title: Text(friend.user.name),
        subtitle: Text('${friend.user.username}\n${friend.user.email}'),
        trailing: IconButton(
            icon: Icon(
              Icons.cancel,
              semanticLabel: 'Remove friendship',
            ),
            onPressed: () async => removeCallback(friend.user.username)),
        isThreeLine: true,
      ),
    );
  }
}

Future<String?> _showAddFriendDialog(BuildContext context) async {
  String? username = "";

  var value = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
            scrollable: true,
            title: Text("Request friendship"),
            content: Column(
              children: [
                Text('Type the username of the friend you want to add:'),
                TextFormField(
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                  autofillHints: [AutofillHints.username],
                  onChanged: (value) {
                    username = value;
                  },
                  onFieldSubmitted: (value) {
                    username = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('CANCEL'),
              ),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('REQUEST FRIENDSHIP'))
            ],
          ));

  if (value) {
    return username;
  } else {
    return null;
  }
}

Future<bool> _showUnfriendDialog(BuildContext context, String name) async {
  return await showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text("Remove friendship"),
            content: SingleChildScrollView(
                child: Text('Are you sure you want to unfriend ${name}?')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('CANCEL'),
              ),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('UNFRIEND'))
            ],
          ));
}

/// timeout in seconds
void _showSnackbar(BuildContext context, String message, [int timeout = 2]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: timeout),
  ));
}
