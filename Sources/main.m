#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

static NSString *const kScript = @"/Users/reinaldomendez/.local/bin/fix-clip-watch";

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong) NSStatusItem *statusItem;
@property (strong) NSTask *task;
@property (assign) BOOL running;
@property (strong) NSWindow *aboutWindow;
- (void)refreshState;
- (void)startWatch;
- (void)stopWatch;
- (BOOL)isRunning;
- (void)killAll;
- (NSImage *)statusImage;
- (void)showMenu:(id)sender;
- (void)toggle:(id)sender;
- (void)refresh:(id)sender;
- (void)quit:(id)sender;
- (void)about:(id)sender;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self refreshState];
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSStatusBarButton *button = self.statusItem.button;
    button.image = [self statusImage];
    button.action = @selector(showMenu:);
    button.target = self;
}

- (NSImage *)statusImage {
    NSString *name = self.running ? @"textformat.abc.dottedunderline" : @"textformat.abc";
    NSImage *img = [NSImage imageWithSystemSymbolName:name accessibilityDescription:@"Fix Clip Watch"];
    return img;
}

- (void)refreshState {
    self.running = [self isRunning];
}

- (BOOL)isRunning {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/pgrep";
    task.arguments = @[@"-f", @"fix-clip-watch"];
    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;
    task.standardError = [NSFileHandle fileHandleWithNullDevice];
    @try { [task launch]; [task waitUntilExit]; } @catch (NSException *e) { return NO; }
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *out = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return out.length > 0;
}

- (void)startWatch {
    if ([self isRunning]) { self.running = YES; return; }
    [[NSFileManager defaultManager] removeItemAtPath:[@"~/.local/run/fix-clip-watch.lock" stringByExpandingTildeInPath] error:nil];
    NSTask *p = [[NSTask alloc] init];
    p.launchPath = @"/bin/zsh";
    p.arguments = @[kScript];
    p.standardOutput = [NSFileHandle fileHandleWithNullDevice];
    p.standardError = [NSFileHandle fileHandleWithNullDevice];
    @try {
        [p launch];
        self.task = p;
        self.running = YES;
        __weak typeof(self) weakSelf = self;
        p.terminationHandler = ^(NSTask *t) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) s = weakSelf;
                if (!s) return;
                s.task = nil;
                s.running = [s isRunning];
                s.statusItem.button.image = [s statusImage];
            });
        };
    } @catch (NSException *e) {
        self.running = [self isRunning];
    }
}

- (void)stopWatch {
    if (self.task) { [self.task terminate]; }
    [self killAll];
    self.task = nil;
    self.running = NO;
}

- (void)killAll {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/pkill";
    task.arguments = @[@"-9", @"-f", @"fix-clip-watch"];
    task.standardOutput = [NSFileHandle fileHandleWithNullDevice];
    task.standardError = [NSFileHandle fileHandleWithNullDevice];
    @try { [task launch]; [task waitUntilExit]; } @catch (NSException *e) {}
    [[NSFileManager defaultManager] removeItemAtPath:[@"~/.local/run/fix-clip-watch.lock" stringByExpandingTildeInPath] error:nil];
}

- (void)showMenu:(id)sender {
    NSMenu *menu = [self makeMenu];
    self.statusItem.menu = menu;
    [self.statusItem.button performClick:nil];
    self.statusItem.menu = nil;
}

- (NSMenu *)makeMenu {
    [self refreshState];
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *status = [[NSMenuItem alloc] initWithTitle:(self.running ? @"Status: Running" : @"Status: Stopped") action:nil keyEquivalent:@""];
    status.enabled = NO;
    [menu addItem:status];
    [menu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *toggle = [[NSMenuItem alloc] initWithTitle:(self.running ? @"Stop" : @"Start") action:@selector(toggle:) keyEquivalent:@"t"];
    toggle.target = self;
    [menu addItem:toggle];
    NSMenuItem *refresh = [[NSMenuItem alloc] initWithTitle:@"Refresh" action:@selector(refresh:) keyEquivalent:@"r"];
    refresh.target = self;
    [menu addItem:refresh];
    [menu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *about = [[NSMenuItem alloc] initWithTitle:@"About" action:@selector(about:) keyEquivalent:@""];
    about.target = self;
    [menu addItem:about];
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit:) keyEquivalent:@"q"];
    quit.target = self;
    [menu addItem:quit];
    return menu;
}

- (void)toggle:(id)sender {
    if (self.running) { [self stopWatch]; } else { [self startWatch]; }
    self.statusItem.button.image = [self statusImage];
}

- (void)refresh:(id)sender {
    [self refreshState];
    self.statusItem.button.image = [self statusImage];
}

- (void)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

- (void)about:(id)sender {
    if (!self.aboutWindow) {
        NSWindow *w = [[NSWindow alloc] initWithContentRect:NSMakeRect(200, 200, 320, 180)
                                                  styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable)
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO];
        w.title = @"Fix Clip Watch";
        NSView *content = w.contentView;
        NSTextField *title = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 130, 280, 24)];
        title.stringValue = @"Fix Clip Watch v0.1.0";
        title.editable = NO;
        title.bordered = NO;
        title.drawsBackground = NO;
        title.font = [NSFont boldSystemFontOfSize:16];
        [content addSubview:title];
        NSTextField *desc = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 90, 280, 40)];
        desc.stringValue = @"Menu bar toggle for fix-clip-watch.";
        desc.editable = NO;
        desc.bordered = NO;
        desc.drawsBackground = NO;
        [content addSubview:desc];

        NSView *badge = [[NSView alloc] initWithFrame:NSMakeRect(190, 12, 118, 28)];
        badge.wantsLayer = YES;
        badge.layer.backgroundColor = [[NSColor colorWithRed:249.0/255.0 green:115.0/255.0 blue:22.0/255.0 alpha:1.0] CGColor];
        badge.layer.cornerRadius = 6;
        NSTextField *badgeText = [[NSTextField alloc] initWithFrame:NSMakeRect(6, 4, 106, 20)];
        badgeText.stringValue = @"#ckpt-fixclipwatch-\"v0.1.0 • toggle menu bar\"";
        badgeText.editable = NO;
        badgeText.bordered = NO;
        badgeText.drawsBackground = NO;
        badgeText.textColor = [NSColor colorWithRed:26.0/255.0 green:15.0/255.0 blue:2.0/255.0 alpha:1.0];
        badgeText.font = [NSFont monospacedSystemFontOfSize:10 weight:NSFontWeightRegular];
        badgeText.lineBreakMode = NSLineBreakByTruncatingTail;
        [badge addSubview:badgeText];
        [content addSubview:badge];

        self.aboutWindow = w;
    }
    [self.aboutWindow makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc > 1) {
            AppDelegate *d = [[AppDelegate alloc] init];
            if (strcmp(argv[1], "--status") == 0) {
                [d refreshState];
                printf("%s\n", d.running ? "running" : "stopped");
                return 0;
            }
            if (strcmp(argv[1], "--stop") == 0) {
                [d stopWatch];
                printf("stopped\n");
                return 0;
            }
            if (strcmp(argv[1], "--start") == 0) {
                [d startWatch];
                printf("started\n");
                return 0;
            }
        }
        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyAccessory];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}