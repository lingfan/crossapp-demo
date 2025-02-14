package proto.friends.friends307 {
	import com.netease.protobuf.*;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	// @@protoc_insertion_point(imports)
	// @@protoc_insertion_point(class_metadata)
	public final class friendsLoadGameShowMessageRequest extends Message implements IExternalizable {
		public var id:int;
		public var friendId:int;
		public var showMesFlag:Boolean;
		public function writeExternal(output:IDataOutput):void {
			WriteUtils.writeTag(output, WireType.VARINT, 1);
			WriteUtils.write_TYPE_INT32(output, id);
			WriteUtils.writeTag(output, WireType.VARINT, 2);
			WriteUtils.write_TYPE_INT32(output, friendId);
			WriteUtils.writeTag(output, WireType.VARINT, 3);
			WriteUtils.write_TYPE_BOOL(output, showMesFlag);
		}
		public function readExternal(input:IDataInput):void {
			var idCount:uint = 0;
			var friendIdCount:uint = 0;
			var showMesFlagCount:uint = 0;
			while (input.bytesAvailable != 0) {
				var tag:Tag = ReadUtils.readTag(input);
				switch (tag.number) {
				case 1:
					if (idCount != 0) {
						throw new IOError('Bad data format.');
					}
					++idCount;
					id = ReadUtils.read_TYPE_INT32(input);
					break;
				case 2:
					if (friendIdCount != 0) {
						throw new IOError('Bad data format.');
					}
					++friendIdCount;
					friendId = ReadUtils.read_TYPE_INT32(input);
					break;
				case 3:
					if (showMesFlagCount != 0) {
						throw new IOError('Bad data format.');
					}
					++showMesFlagCount;
					showMesFlag = ReadUtils.read_TYPE_BOOL(input);
					break;
				default:
					ReadUtils.skip(input, tag.wireType);
				}
			}
			if (idCount != 1) {
				throw new IOError('Bad data format.');
			}
			if (friendIdCount != 1) {
				throw new IOError('Bad data format.');
			}
			if (showMesFlagCount != 1) {
				throw new IOError('Bad data format.');
			}
		}
	}
}
