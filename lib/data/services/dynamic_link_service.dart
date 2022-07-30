class DynamicLinkService {
  static String generateDynamicLink({String? path}) {
    path ??= '/';
    
    if (!path.startsWith('/')) {
      path = '/' + path;
    }

    const apn = 'com.statera.statera'; // android
    const ibi = 'com.statera.statera'; // apple
    const isi = '1609503817'; // app store
    final link = 'https://statera-0.web.app$path';
    
    return 'https://statera.page.link?link=$link&apn=$apn&ibi=$ibi&isi=$isi';
  }
}
