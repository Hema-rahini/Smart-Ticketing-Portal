'use client'

import { useState, useRef, useEffect } from 'react'
import { useAppStore as useStore } from '@/lib/store'
import { cn } from '@/lib/utils'
import { format } from 'date-fns'
import {
  Send,
  Search,
  Plus,
  MoreVertical,
  Paperclip,
  Image,
  Smile,
  Hash,
  Users,
  MessageSquare,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'

export function ChatInterface() {
  const { currentUser, users, channels, messages, departments, sendMessage, addNotification } = useStore()
  const [activeTab, setActiveTab] = useState<'teams' | 'direct'>('teams')
  const [selectedChannelId, setSelectedChannelId] = useState<string>('')
  const [selectedDirectUser, setSelectedDirectUser] = useState<User | null>(null)
  const [newMessage, setNewMessage] = useState('')
  const [searchQuery, setSearchQuery] = useState('')
  const messagesEndRef = useRef<HTMLDivElement>(null)

  // Dynamically generate department team channels
  const teamChannels = departments.map(d => ({
    id: `channel-dept-${d.id}`,
    name: `${d.name} Team`,
    department: d.name,
    members: users.filter(u => u.department === d.name).map(u => u.id),
  }))

  const activeChannel = teamChannels.find(c => c.id === selectedChannelId) || teamChannels[0]

  useEffect(() => {
    if (!selectedChannelId && teamChannels.length > 0) {
      setSelectedChannelId(teamChannels[0].id)
    }
  }, [teamChannels])

  const getUser = (userId: string) => users.find(u => u.id === userId)

  // Messages for active conversation
  const currentConversationMessages = activeTab === 'teams'
    ? messages.filter(m => m.channelId === activeChannel?.id)
    : messages.filter(m =>
        (m.senderId === currentUser?.id && m.receiverId === selectedDirectUser?.id) ||
        (m.senderId === selectedDirectUser?.id && m.receiverId === currentUser?.id)
      )

  const filteredTeams = teamChannels.filter(ch =>
    ch.name.toLowerCase().includes(searchQuery.toLowerCase())
  )

  const filteredUsers = users.filter(u =>
    u.id !== currentUser?.id &&
    (u.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
     (u.department && u.department.toLowerCase().includes(searchQuery.toLowerCase())))
  )

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [currentConversationMessages.length])

  const handleSendMessage = () => {
    if (!newMessage.trim() || !currentUser) return

    if (activeTab === 'teams' && activeChannel) {
      sendMessage({
        content: newMessage,
        senderId: currentUser.id,
        channelId: activeChannel.id,
      })
    } else if (activeTab === 'direct' && selectedDirectUser) {
      sendMessage({
        content: newMessage,
        senderId: currentUser.id,
        receiverId: selectedDirectUser.id,
      })

      // Send notification to recipient
      addNotification({
        type: 'comment_added',
        userId: currentUser.id,
        targetId: selectedDirectUser.id,
        description: `sent you a direct chat message: "${newMessage.slice(0, 30)}${newMessage.length > 30 ? '...' : ''}"`,
      })
    }
    setNewMessage('')
  }

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSendMessage()
    }
  }

  return (
    <div className="flex h-[calc(100vh-10rem)] gap-4">
      {/* Channels & Team Members Sidebar */}
      <Card className="w-80 shrink-0 flex flex-col">
        <CardHeader className="pb-3 space-y-3">
          <div className="flex items-center justify-between">
            <CardTitle className="text-lg flex items-center gap-2">
              <MessageSquare className="h-5 w-5 text-primary" />
              Chat Hub
            </CardTitle>
          </div>

          {/* Navigation Tabs */}
          <div className="flex p-1 bg-muted rounded-lg text-xs font-medium">
            <button
              onClick={() => {
                setActiveTab('teams')
                if (!selectedChannelId && teamChannels.length > 0) {
                  setSelectedChannelId(teamChannels[0].id)
                }
              }}
              className={cn(
                'flex-1 py-1.5 rounded-md transition-all flex items-center justify-center gap-1.5',
                activeTab === 'teams'
                  ? 'bg-background text-foreground shadow-sm'
                  : 'text-muted-foreground hover:text-foreground'
              )}
            >
              <Users className="h-3.5 w-3.5" />
              Team Channels
            </button>
            <button
              onClick={() => {
                setActiveTab('direct')
                if (!selectedDirectUser && users.length > 0) {
                  const firstOther = users.find(u => u.id !== currentUser?.id)
                  if (firstOther) setSelectedDirectUser(firstOther)
                }
              }}
              className={cn(
                'flex-1 py-1.5 rounded-md transition-all flex items-center justify-center gap-1.5',
                activeTab === 'direct'
                  ? 'bg-background text-foreground shadow-sm'
                  : 'text-muted-foreground hover:text-foreground'
              )}
            >
              <MessageSquare className="h-3.5 w-3.5" />
              Direct Chat
            </button>
          </div>

          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder={activeTab === 'teams' ? "Search team channels..." : "Search team members..."}
              className="pl-9 h-9 text-xs"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
        </CardHeader>
        <CardContent className="flex-1 p-0 overflow-hidden">
          <ScrollArea className="h-full px-3 pb-3">
            {activeTab === 'teams' ? (
              <div className="space-y-1">
                {filteredTeams.map((channel) => {
                  const isActive = activeChannel?.id === channel.id

                  return (
                    <button
                      key={channel.id}
                      onClick={() => setSelectedChannelId(channel.id)}
                      className={cn(
                        'w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-left transition-colors',
                        isActive
                          ? 'bg-primary text-primary-foreground'
                          : 'hover:bg-secondary text-foreground'
                      )}
                    >
                      <Users className="h-4 w-4 shrink-0" />
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium truncate">{channel.name}</p>
                        <p className={cn(
                          'text-xs truncate',
                          isActive ? 'text-primary-foreground/70' : 'text-muted-foreground'
                        )}>
                          {channel.members.length} {channel.members.length === 1 ? 'member' : 'members'}
                        </p>
                      </div>
                      <Badge variant={isActive ? 'secondary' : 'outline'} className="text-[10px]">
                        Team
                      </Badge>
                    </button>
                  )
                })}
              </div>
            ) : (
              <div className="space-y-1">
                {filteredUsers.map((user) => {
                  const isActive = selectedDirectUser?.id === user.id

                  return (
                    <button
                      key={user.id}
                      onClick={() => setSelectedDirectUser(user)}
                      className={cn(
                        'w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-left transition-colors',
                        isActive
                          ? 'bg-primary text-primary-foreground'
                          : 'hover:bg-secondary text-foreground'
                      )}
                    >
                      <Avatar className="h-8 w-8 shrink-0">
                        <AvatarImage src={user.avatar} />
                        <AvatarFallback className="text-xs bg-muted text-foreground">
                          {user.name.split(' ').map(n => n[0]).join('')}
                        </AvatarFallback>
                      </Avatar>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium truncate">{user.name}</p>
                        <p className={cn(
                          'text-xs truncate capitalize',
                          isActive ? 'text-primary-foreground/70' : 'text-muted-foreground'
                        )}>
                          {user.role} • {user.department || 'General'}
                        </p>
                      </div>
                    </button>
                  )
                })}
              </div>
            )}
          </ScrollArea>
        </CardContent>
      </Card>

      {/* Chat Area */}
      <Card className="flex-1 flex flex-col">
        {(activeTab === 'teams' && activeChannel) || (activeTab === 'direct' && selectedDirectUser) ? (
          <>
            {/* Chat Header */}
            <CardHeader className="pb-3 border-b">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  {activeTab === 'teams' ? (
                    <>
                      <div className="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center">
                        <Users className="h-5 w-5 text-primary" />
                      </div>
                      <div>
                        <CardTitle className="text-lg">{activeChannel?.name}</CardTitle>
                        <p className="text-xs text-muted-foreground">
                          {activeChannel?.members.length} team members in {activeChannel?.department}
                        </p>
                      </div>
                    </>
                  ) : (
                    <>
                      <Avatar className="h-10 w-10">
                        <AvatarImage src={selectedDirectUser?.avatar} />
                        <AvatarFallback className="bg-primary text-primary-foreground text-sm">
                          {selectedDirectUser?.name?.split(' ').map(n => n[0]).join('')}
                        </AvatarFallback>
                      </Avatar>
                      <div>
                        <CardTitle className="text-lg">{selectedDirectUser?.name}</CardTitle>
                        <p className="text-xs text-muted-foreground capitalize">
                          {selectedDirectUser?.role} • {selectedDirectUser?.department || 'General Department'}
                        </p>
                      </div>
                    </>
                  )}
                </div>
              </div>
            </CardHeader>

            {/* Messages */}
            <CardContent className="flex-1 p-0 overflow-hidden">
              <ScrollArea className="h-full">
                <div className="p-4 space-y-4">
                  {currentConversationMessages.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-12 text-muted-foreground">
                      <MessageSquare className="h-12 w-12 mb-4 opacity-50" />
                      <p className="text-sm font-medium">No messages yet</p>
                      <p className="text-xs">Start messaging {activeTab === 'teams' ? activeChannel?.name : selectedDirectUser?.name}!</p>
                    </div>
                  ) : (
                    currentConversationMessages.map((message, index) => {
                      const sender = getUser(message.senderId)
                      const isCurrentUser = message.senderId === currentUser?.id
                      const showAvatar = index === 0 || currentConversationMessages[index - 1].senderId !== message.senderId

                      return (
                        <div
                          key={message.id}
                          className={cn(
                            'flex gap-3',
                            isCurrentUser && 'flex-row-reverse'
                          )}
                        >
                          {showAvatar ? (
                            <Avatar className="h-8 w-8 shrink-0">
                              <AvatarImage src={sender?.avatar} />
                              <AvatarFallback className="text-xs bg-primary text-primary-foreground">
                                {sender?.name?.split(' ').map(n => n[0]).join('')}
                              </AvatarFallback>
                            </Avatar>
                          ) : (
                            <div className="w-8" />
                          )}
                          <div className={cn(
                            'flex flex-col max-w-[70%]',
                            isCurrentUser && 'items-end'
                          )}>
                            {showAvatar && (
                              <div className={cn(
                                'flex items-center gap-2 mb-1',
                                isCurrentUser && 'flex-row-reverse'
                              )}>
                                <span className="text-xs font-medium">{sender?.name}</span>
                                <span className="text-[10px] text-muted-foreground">
                                  {format(new Date(message.createdAt), 'h:mm a')}
                                </span>
                              </div>
                            )}
                            <div className={cn(
                              'rounded-2xl px-4 py-2',
                              isCurrentUser
                                ? 'bg-primary text-primary-foreground rounded-tr-sm'
                                : 'bg-secondary text-secondary-foreground rounded-tl-sm'
                            )}>
                              <p className="text-sm whitespace-pre-wrap">{message.content}</p>
                            </div>
                          </div>
                        </div>
                      )
                    })
                  )}
                  <div ref={messagesEndRef} />
                </div>
              </ScrollArea>
            </CardContent>

            {/* Message Input */}
            <div className="p-4 border-t">
              <div className="flex items-center gap-2">
                <Button variant="ghost" size="icon" className="shrink-0">
                  <Plus className="h-4 w-4" />
                </Button>
                <div className="relative flex-1">
                  <Input
                    placeholder={activeTab === 'teams' ? `Message ${activeChannel?.name}...` : `Message ${selectedDirectUser?.name}...`}
                    className="pr-24"
                    value={newMessage}
                    onChange={(e) => setNewMessage(e.target.value)}
                    onKeyPress={handleKeyPress}
                  />
                  <div className="absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-1">
                    <Button variant="ghost" size="icon" className="h-7 w-7">
                      <Paperclip className="h-4 w-4" />
                    </Button>
                    <Button variant="ghost" size="icon" className="h-7 w-7">
                      <Smile className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
                <Button onClick={handleSendMessage} disabled={!newMessage.trim()}>
                  <Send className="h-4 w-4" />
                </Button>
              </div>
            </div>
          </>
        ) : (
          <CardContent className="flex-1 flex items-center justify-center">
            <div className="text-center text-muted-foreground">
              <MessageSquare className="h-12 w-12 mx-auto mb-4 opacity-50" />
              <p>Select a channel to start messaging</p>
            </div>
          </CardContent>
        )}
      </Card>
    </div>
  )
}
